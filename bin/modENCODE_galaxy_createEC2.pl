#!/usr/bin/perl 

#
# written by:
# Ziru Zhou, ziruzhou@gmail.com
# Kar Ming Chu, mr.kar.ming.chu@gmail.com
# Quang Trinh, quang.trinh@gmail.com
# please send your questions/comments to help@modencode.org 
#

use strict;
use warnings;
use File::Basename;
use VM::EC2;
use File::Temp qw(tempfile);

#global variables
#=================================================================
my $keyPair;
my $securityGroup;
my $userDataFile;
my $clusterName;
my $clusterPassword;
my $accessKey;
my $secretKey;
my $instanceType;
my $instanceName;
my $ami;
my $availabilityZone;
	

#function declarations
#=================================================================
#function which creates the textfile with the cloudman settings
sub createCloudmanConfig
{
	my $clusterName = shift;
	my $clusterPassword = shift;
	my $accessKey = shift;
	my $secretKey = shift;
	my $userDataFile = shift;

	#open the file with provided name to write data
	open FILE, '>'.$userDataFile or die "Unable to create $userDataFile\n";
	
	print FILE "cluster_name: $clusterName\n";
	print FILE "password: $clusterPassword\n";
	print FILE "access_key: $accessKey\n";
	print FILE "secret_key: $secretKey\n";

	close FILE;	
}

sub parseOptions()
{
	#assign config filename, open and read its contents into an array
	my $filename = $ARGV[0];
	my @line;
	my @options;

	open FILE, $filename or die "Could not find ${filename}\n";
	@options = <FILE>;

	#more options maybe added later in configuration file following format of:
	#	label: value
	foreach my $i (@options)
	{
		@line = split(" ", $i);
		if($i =~ /^AMI:/)
		{
			$ami = $line[1];	
		}
		elsif($i =~ /^KEY_PAIR:/)
		{
			$keyPair = $line[1];
		}
		elsif($i =~ /^SECURITY_GROUP:/)
		{
			$securityGroup = $line[1];
		}
		elsif($i =~ /^CLUSTER_NAME:/)
		{
			$clusterName = $line[1];
		}	
		elsif($i =~ /^CLOUDMAN_PASSWORD:/)
		{
			$clusterPassword = $line[1];
		}	
		elsif($i =~ /^ACCESS_KEY:/)
		{
			$accessKey = $line[1];
		}	
		elsif($i =~ /^SECRET_KEY:/)
		{
			$secretKey = $line[1];
		}	
		elsif($i =~ /^INSTANCE_TYPE:/)
		{
			$instanceType = $line[1];
		}
		elsif($i =~ /^AVAILABILITY_ZONE:/)
		{
			$availabilityZone = $line[1];
		}
		elsif($i =~ /^INSTANCE_NAME:/)
		{
			$instanceName = $line[1];
		}
	}

	close FILE;

	#print out existing options
	printf ("\nLaunching Galaxy with the following information as defined in config file '$ARGV[0]':");
	printf ("\n %-15s \t %-30s", "AMI:", $ami);
	printf ("\n %-15s \t %-30s", "INSTANCE_NAME:", $instanceName);
	printf ("\n %-15s \t %-30s", "KEY_PAIR:", $keyPair);
	printf ("\n %-15s \t %-30s", "SECURITY_GROUP:", $securityGroup);
	printf ("\n %-15s \t %-30s", "INSTANCE_TYPE:", $instanceType);
	printf ("\n %-15s \t %-30s", "AVAILABILITY_ZONE:", $availabilityZone);
	print "\n";
}

#function to check if the enviornment has been set, if not run ". env.sh"
sub checkEnvironments
{
	if (not exists($ENV{"EC2_ACCESS_KEY"})) {
		print "\nEC2_ACCESS_KEY variable is not set - see README file on how to set this variable\n\n";
		exit (1);
	}
	if (not exists($ENV{"EC2_SECRET_KEY"})) {
		print "\nEC2_SECRET_KEY variable is not set - see README file on how to set this variable\n\n";
		exit (1);
	}
}

#function for creating the key file
sub createKeypair 
{
	my $key = shift;
	my $outputFileName = $key . ".pem";

	# get new EC2 object
	my $ec2 = VM::EC2->new(-endpoint   => 'http://ec2.amazonaws.com');
	my @pairs = $ec2->describe_key_pairs();
	my $found = 0;
	foreach (@pairs) {
		my $fingerprint = $_->keyFingerprint;
		my $name = $_->keyName;
		if ($key eq $name) {
			$found = 1;
			last;
		}
	}
	my $newKey;
	if ($found == 1) {
		print "\nKeypair '$key' exists ... skip creating it ...\n";
	} else {
		print "\nCreating keypair '$key' ";
		$newKey = $ec2->create_key_pair($key);
		open(KEYFILE,'>' . $outputFileName);
		print KEYFILE $newKey->privateKey;
		close (KEYFILE);
	}
}

#function for creating the security group, group options maybe set to be more flexible later
sub createSecurityGroup 
{
	my $group = shift;

	# get new EC2 object
        my $ec2 = VM::EC2->new(-endpoint   => 'http://ec2.amazonaws.com');
	my @sg = $ec2->describe_security_groups();
	my $found = 0;
	for my $g (@sg) {
		if ($g->groupName eq $group) {
			$found = 1;
			last;
		}
	}
	if ($found == 1) {
		print "\nSecurity group '$group' exists ... skip creating it ...\n";
	} else {
		print "\nCreating security group '$group' ";
		my $g = $ec2->create_security_group(-group_name=>$group,-group_description=>'Security group to use with modENCODE Galaxy'); 
		# HTTP
		$g->authorize_incoming(-protocol  => 'tcp',-port => 80);
		# SSH
		$g->authorize_incoming(-protocol  => 'tcp',-port => 22);
		# cloud controller web interface
		$g->authorize_incoming(-protocol  => 'tcp',-port => 42284);
		# FTP 
		$g->authorize_incoming(-protocol  => 'tcp',-ports => "20..21");
		# passive FTP 
		$g->authorize_incoming(-protocol  => 'tcp',-ports => "30000..30100");
		# allow machines in cluster to talk to each other 
		$g->authorize_incoming(-protocol  => 'tcp',-port => "0..65535", -group => $group);

		# write new security group to AWS
		if (($g->update()) ) {
			print " ... done\n\n";
		} else {
			print " ... error creating security group '$group'\n\n";
			exit (1);
		}
	}
}

#sub function for autodetecting when all volumes are ready to be labeled 
sub labelVolumes
{
	my $instanceID = shift;
	my $readycounter = 0;
	my $timeoutcounter = 30;
	my $timeout = 1;
	
	#continuously run describe instance command to determine if there are 4 listed attached volumes
	while($timeoutcounter > 0)
	{
		my @ec2cmd = `ec2-describe-instances $instanceID`;
	
		foreach my $i (@ec2cmd)
		{	
			#counting the lines that start with blockdevice to obtain how many volumes are attached
			if($i =~ /^BLOCKDEVICE/)
			{
				$readycounter++;
			}
		}

		#if we determine there are 4 volumes attached, break out of the loop 
		if($readycounter == 4)
		{
			#flip off timeout switch
			$timeout = 0;

			#call name volumes function and exit loop 
			print "\n\nAll Galaxy volumes have been attached ...\n";
			system("bin/modENCODE_galaxy_namevolumes.pl $instanceID");
			last;
		}
		else
		{
			#reset our current count
			$readycounter = 0;

			#otherwise we have to decrease a timeout counter and wait 30 seconds
			$timeoutcounter--;
			sleep 30;
		}
	}
	
	#if in the case that 900s have passed we will timeout and exit -- this should only happen in extreme cases 
	if($timeout == 1)
	{
		print "\n\nOne or more volumes are not attached within the allowed time!\n";
		print "Please label your Galaxy volumes manually later by running:";
		print "\n\n\tbin/modENCODE_galaxy_namevolumes.pl $instanceID";
		print "\n";
	}
}

#function which creates the instance on the amazon cloud 
sub createGalaxyInstance 
{
	my $ami = shift;
	my $keyPair = shift;
	my $securityGroup = shift;
	my $galaxyUserDataFile = shift;
	my $instanceType = shift;
	my $instanceName = shift;
	my $availabilityZone = shift;
	my $instanceID;
	my $cmdOutput;

	print "\nCreating Galaxy instance ... ";
	print "\nami $ami";
	print "\nkeyname $keyPair";
	print "\nsecurityGroup $securityGroup";
	print "\nuserDataFile $galaxyUserDataFile";
	print "\nzone $availabilityZone";
	print "\ninstanceType $instanceType";
	print "\n";
	 
	# get new EC2 object
 	#my $ec2 = VM::EC2->new(-endpoint   => 'http://ec2.amazonaws.com');
 	my $ec2 = VM::EC2->new(-endpoint   => 'http://ec2.amazonaws.com');
	my @instances = $ec2->run_instances(-image_id => $ami, -key_name      =>$keyPair,
                                       -security_group=>$securityGroup,
                                       -min_count     =>1,
                                       -userData => $galaxyUserDataFile,
                                       -availability_zone=> $availabilityZone,
                                       -instance_type => $instanceType);

	print "\n status " . $instances[0]->current_status;
	print "\n metadata " . $ec2->instance_metadata;

	# wait for instances to be up and running
	$ec2->wait_for_instances(@instances);
	print " done \n";
	$instanceID = $instances[0]->instanceId;

	#my $tags = $instances[0]->tags;
	#$tags->describe_tags(-key => "Name", -value => $instanceName);

	my $shareInstanceCluster = "cm-d945c4daad85b97ee167273c2ade5209/shared/2012-09-19--14-56";
	print "\n\nmodENCODE Galaxy Share-an-Instance Cluster string:";
	print "\n\t" . $shareInstanceCluster ;
	
	print "\n\nGalaxy is starting up.  This may take a minute or two.  Please go to the Cloudman console URL below to configure your Galaxy cluster:\n\t" . $instances[0]->dnsName . "/cloud";

	print "\n\nTo access your Galaxy interface, go to this URL:\n\t" . $instances[0]->dnsName;
	print "\n\nTo login to your Galaxy, please use this command:\n\tssh -i " . $keyPair . ".pem  ubuntu@" . $instances[0]->dnsName;
	print "\n\nPlease send questions/comments to help\@modencode.org\n\n";
	

	# label the instance 
	#$cmdOutput = `ec2-create-tags $instanceID -t Name=$instanceName`;
	
	#my $URL = getGalaxyURL($instanceID);
	


	#label Galaxy volumes
	#labelVolumes($instanceID);
	
}

#sub function which is used to get the id of the instance being launched
sub getInstanceID 
{
	my $str = shift;
	my $instanceID;
	my @fields = split ("\n",$str);

	foreach my $l (@fields)
	{
		if ($l =~ /^INSTANCE/) 
		{
			my @f = split("\t",$l);
			$instanceID = $f[1];
			last;
		}
	}
	return $instanceID;
}

#sub function used to output the url used for cloudman and ssh
sub getGalaxyURL 
{
	my $instanceID = shift;
	my @cmdOutput;
	my $URL;
	my $complete = 0;
	my @fields;

	# wait for another 45 seconds to ensure all services are started 
	sleep 45;

	while (!$complete) 
	{
		# wait another 5 secs before trying again
		sleep 5;
	
		@cmdOutput = `ec2-describe-instances $instanceID`;
		foreach my $line (@cmdOutput)
		{
			if (($line =~ /^INSTANCE/) && ($line =~ /running/)) 
			{
				my @f = split("\t",$line);
				$URL = $f[3];
				$complete = 1;
				last;
			}
		}
	}

	return $URL;
}


#function which prints out the proper format of the function when the inputs are given incorrectly
sub usage()
{
	print "\n";
	print "This script creates an instance of Galaxy on Amazon. Please send questions/comments to help\@modencode.org.";
	print "\n\n\tusage: perl " . basename($0) . "  [ CONFIG_FILE ] ";
	print "\n\n\t\tFor example: \t $0 config.txt";
	print "\n\n";
	exit 2;
}


#function calls
#=================================================================
if(@ARGV != 1)
{
	usage();
}
else
{
	checkEnvironments();
	parseOptions();

	# create a temp file for Galaxy user data 
	#$userDataFile = new File::Temp( UNLINK => 0 );
	$userDataFile = "galaxy.tmp.txt";

	# NOTE: for debugging. remove later 
	print "\n Galaxy tmp user data $userDataFile\n";

	createCloudmanConfig($clusterName, $clusterPassword, $accessKey, $secretKey, $userDataFile);

	if ( (length($keyPair) == 0) || (length($securityGroup) == 0) || (length($userDataFile) == 0) || (length($instanceType) == 0) || (length($instanceName) == 0) || (length($ami) == 0) || (length($availabilityZone) == 0)) {
		print "\n\nPlease check your config file and make sure all options are defined!\n\n";
		exit (1);
	}

	createKeypair($keyPair);
	createSecurityGroup($securityGroup);
	createGalaxyInstance($ami, $keyPair, $securityGroup, $userDataFile, $instanceType, $instanceName, $availabilityZone);
}
