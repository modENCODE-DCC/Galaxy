#!/usr/bin/perl 

#
# written by the following people from modENCODE DCC group:
# Ziru Zhou, ziruzhou@gmail.com
# Kar Ming Chu, mr.kar.ming.chu@gmail.com
# Quang Trinh, quang.trinh@gmail.com
# please send your questions/comments to modENCODE DCC <help@modencode.org>
#

use strict;
use warnings;
use File::Basename;
use File::Temp qw(tempfile);

#global variables
#=================================================================
my $keyPair;
my $securityGroup;
my $clusterName;
my $userDataFile;
my $clusterPassword;
my $instanceType;
my $instanceName;
my $ami;
my $region = ""; 
my $availabilityZone = "";
	

#function declarations
#=================================================================
#function which creates the textfile with the cloudman settings
sub createCloudmanConfigFile
{
	my $clusterName = shift;
	my $clusterPassword = shift;
	my $userDataFile = shift;


	#open the file with provided name to write data
	open FILE, '>'.$userDataFile or die "Unable to create $userDataFile\n";
	
	print FILE "cluster_name: $clusterName\n";
	print FILE "password: $clusterPassword\n";
	print FILE "access_key: $ENV{'AWS_ACCESS_KEY'}\n";
	print FILE "secret_key: $ENV{'AWS_SECRET_KEY'}\n";

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
		elsif($i =~ /^INSTANCE_TYPE:/)
		{
			$instanceType = $line[1];
		}
		elsif($i =~ /^REGION:/)
		{
			$region = $line[1];
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

}

#function to check if the enviornment has been set, if not run ". env.sh"
sub checkEnvironments
{
	# check to see if AWS_ACCESS_KEY and AWS_SECRET_KEY variables are set 
	if ((length($ENV{'AWS_ACCESS_KEY'}) == 0) || (length($ENV{'AWS_SECRET_KEY'}) == 0)) {
		print "\nPlease set your AWS_ACCESS_KEY and AWS_SECRET_KEY environment variables - see README file on how to do this.\n\n";
		exit(1);
	}
}

#function for creating the key file
sub createKeypair 
{
	my $key = shift;
	my $region = shift;

	my $outputFileName = $key . ".pem";

	my $cmdOutput = `ec2-describe-keypairs --region $region`;

	#if key exists, skip creating it otherwise make the key 
	if ($cmdOutput =~ /$key/)
	{
		print "\nKeypair '$key' exists ... skip creating it ...\n";
	} 
	else
	{
		print "\nCreating keypair '$key' ";
		$cmdOutput = `ec2-create-keypair $keyPair --region $region > $outputFileName`;
	
		# change permission so that key is not accessible by other users	
		system ("chmod 600 $outputFileName");
		print "... done\n";
	}
}

#function for creating the security group, group options maybe set to be more flexible later
sub createSecurityGroup 
{
	my $group = shift;
	my $region = shift;

	my $cmdOutput = `ec2-describe-group --region $region `;

	#if security group exists, skip process otherwise create the group
	if (($cmdOutput =~ /^GROUP/) && ($cmdOutput =~ /$group/)) 
	{
		print "\nSecurity group '$group' exists ... skip creating it ...\n";
	}
	else 
	{
		print "\nCreating security group '$group' ";
		$cmdOutput = `ec2-create-group $group --region $region -d \"Security group to use with Galaxy ( created by modENCODE_galaxy_create.pl )\"`;
	
		$cmdOutput = `ec2-authorize $group -P tcp -p 80`;       # HTTP
		$cmdOutput = `ec2-authorize $group -P tcp -p 22`;       # SSH
		$cmdOutput = `ec2-authorize $group -P tcp -p 42284`;    # Cloud controller web interface
		$cmdOutput = `ec2-authorize $group -P tcp -p 20-21`;   	# FTP 
		$cmdOutput = `ec2-authorize $group -P tcp -p 30000-30100`;    # passive FTP 
		$cmdOutput = `ec2-authorize $group -P tcp -p -1 -o $group`;    # Allow machines in cluster to talk
		print "... done\n";
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
			print "\n\nAll 3 Galaxy volumes have been attached ...\n";
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

# return array of 2 elements: region and available zone 
sub getRegionAndAvailableZone 
{
	my $cmdOutput;
	my $cmd = "ec2-describe-availability-zones";
	my @data = ();

	#  2>&1 to capture both STDERR and STDOUT
	$cmdOutput =`$cmd 2>&1`;
	my @fields = split ("\n",$cmdOutput);
	foreach my $l (@fields)
	{
		if ($l =~ /^AVAILABILITYZONE/) {
			@fields = split ("\t",$l);
			push (@data, $fields[3]);
			push (@data, $fields[1]);
			return @data;
		}
	}
	print "\n\nNo default region and available zone!\n\n";
	exit (1);
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
	my $region = shift;
	my $availabilityZone = shift;
	my $instanceID;
	my $cmd ;
	my $cmdOutput;


	$cmd ="ec2-run-instances $ami -k $keyPair -g $securityGroup -f $galaxyUserDataFile -t $instanceType --region $region --availability-zone $availabilityZone ";	

	#  2>&1 to capture both STDERR and STDOUT
	$cmdOutput =`$cmd 2>&1`;
	if (checkRunInstanceError($cmdOutput) == 1) {
		print "\nError launching Galaxy:";
		print "\n\n$cmdOutput";
		print "\n\n";
		exit (1);
	} else {
		print "\nLaunching Galaxy instance ... ";
	}

	$instanceID = getInstanceID($cmdOutput);

	# label the instance 
	$cmdOutput = `ec2-create-tags $instanceID  -t Name=$instanceName`;
	
	my $URL = getGalaxyURL($instanceID);
	
	#my $shareInstanceCluster = "cm-d945c4daad85b97ee167273c2ade5209/shared/2012-09-25--16-07";
	#my $shareInstanceCluster = "cm-53052bb7c819455c6b3da1743e85392d/shared/2012-10-10--19-34";
	#print "\n\nmodENCODE Galaxy Share-an-Instance Cluster string:";
	#print "\n\t" . $shareInstanceCluster ;

	print "\n\nGalaxy is starting up.  Please go to the Cloudman console URL below to configure your Galaxy cluster:\n\t" . $URL . "/cloud";

	print "\n\nNOTE: If you get a 'Failed to Connect' message in your browser, then your CloudMan console is\nnot ready yet.  Reload your CloudMan console and wait until it is ready.";

	print "\n\nWaiting for Galaxy, PostgreSQL, SGE, and file systems services to start ...";

	#label Galaxy volumes
	labelVolumes($instanceID);
	
	print "\n\nTo access your Galaxy interface, go to this URL:\n\t" . $URL;
	print "\n\nTo login to your Galaxy, use this command:\n\tssh -i " . $keyPair . ".pem  ubuntu@" . $URL ;
	print "\n\nPlease send questions/comments to help\@modencode.org\n\n";
}

# check for error after running an instance 
# return 0 if there is no error
# return 1 if there is an error 
sub checkRunInstanceError
{
	my $str = shift;
	my $instanceID = "";
	my @fields = split ("\n",$str);

	foreach my $l (@fields)
	{
		if ($l =~ /^RESERVATION/) 
		{
			return 0;
		}
	}
	return 1;
}


#sub function which is used to get the id of the instance being launched
sub getInstanceID 
{
	my $str = shift;
	my $instanceID = "";
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

	# Galaxy is only supported inteh US EAST region - see http://wiki.g2.bx.psu.edu/CloudMan
	if (((length($region) > 0) && ($region !~ /east/)) 
		|| ((length($availabilityZone) > 0) && ($availabilityZone !~ /east/)))
	{
		print "\n\nAt the moment, Galaxy is supported only in US East region!  Please change your configuration!\n\n";
		exit (1);
	}
	
	# get the default region and availability zone if users didn't put them in config file
	if ((length($region) == 0) || (length($availabilityZone)==0)) 
	{
		($region, $availabilityZone) = getRegionAndAvailableZone();
	}

        # temp file to store Galaxy user data
        $userDataFile = new File::Temp( UNLINK => 0 );
	system ("chmod ago+rx $userDataFile");
	print "\ntmp Galaxy user data file '$userDataFile'\n";

	createCloudmanConfigFile($clusterName, $clusterPassword, $userDataFile);

	if ( (length($keyPair) == 0) || (length($securityGroup) == 0) || (length($userDataFile) == 0) || (length($instanceType) == 0) || (length($instanceName) == 0) || (length($ami) == 0) ) {
		print "\n\nPlease check your config file and make sure all options are defined!\n\n";
		exit (1);
	}
	
	#print out existing options
	printf ("\nLaunching Galaxy with the following information as defined in config file '$ARGV[0]':");
	printf ("\n %-15s \t %-30s", "GALAXY AMI:", $ami);
	printf ("\n %-15s \t %-30s", "INSTANCE_NAME:", $instanceName);
	printf ("\n %-15s \t %-30s", "KEY_PAIR:", $keyPair);
	printf ("\n %-15s \t %-30s", "SECURITY_GROUP:", $securityGroup);
	printf ("\n %-15s \t %-30s", "INSTANCE_TYPE:", $instanceType);
	printf ("\n %-15s \t %-30s", "REGION:", $region);
	printf ("\n %-15s \t %-30s", "AVAILABILITY_ZONE:", $availabilityZone);
	print "\n";

	createKeypair($keyPair,$region);
	createSecurityGroup($securityGroup, $region);
	createGalaxyInstance($ami, $keyPair, $securityGroup, $userDataFile, $instanceType, $instanceName, $region, $availabilityZone);
	# remove temp Galaxy user data 
	#system ("rm $userDataFile");
}
