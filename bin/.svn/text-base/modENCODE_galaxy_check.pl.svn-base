#!/usr/bin/perl 
use strict;
use warnings;
use File::Basename;


if ( @ARGV != 1 ) {
        print "\n";
        print "This script checks Galaxy environments.  Please send questions/comments to help\@modencode.org.";
        print "\n\nusage: perl " . basename($0) . " [ USER_DATA_FILE ] ";

	print "\n\tUSER_DATA_FILE\tGalaxy user data file.  See README file for information on contents of this file.";

	print "\n\nFor example:\n\t$0 galaxy_user_data.txt ";
	print "\n\n";
	exit 2;
}

my $userDataFile = $ARGV[0];

checkEnvironments();
checkGalaxy($userDataFile);

print "\n";


sub checkEnvironments {
	
	#-- capture STDERR as well as STDOUT
	my $output = `ec2-describe-regions 2>&1`;

	if ($? == -1) {
		print "\nplease make sure your environments are set - see README file on how to set your environments!\n\n";
		exit (0);
	}
}


sub checkGalaxy{

	my $userDataFile = shift;
	my $clusterName = getGalaxyClusterName($userDataFile);
	print "\nclusterName\t'$clusterName'";
	my $instanceID = getInstanceID($clusterName);
	print "\ninstanceID\t'$instanceID'";
	checkMountedGalaxyVolumes($instanceID, $clusterName);
	
}

sub checkMountedGalaxyVolumes {
	my $instanceID = shift;
	my $clusterName = shift;
	my $volID;
	my $hostName ;

	# hash table to keep track of what already mounted 
	my %mounted = ();
						
	$mounted{"galaxyTools"} = 0;
	$mounted{"galaxyIndices"} = 0;
	$mounted{"galaxyData"} = 0;

	my $cmdOutput = `ec2-describe-instances $instanceID`;

	#print "\n\n\ndescribe instance output \n$cmdOutput\n\n\n";
	my @fields = split ("\n",$cmdOutput);
	foreach my $l (@fields) {
		if (($l =~ /^INSTANCE/) ){
			# INSTANCE	i-5424852e	ami-da58aab3	ec2-184-72-171-86.compute-1.amazonaws.com	ip-10-90-246-99.ec2.internal
			my @f = split("\t",$l);
			$hostName = $f[3];
		} elsif (($l =~ /^BLOCKDEVICE/) && ($l =~ /dev/) ){
			# BLOCKDEVICE	/dev/sda1	vol-9456c7ef	2012-09-03T13:33:52.000Z	true		
			my @f = split("\t",$l);
			$volID = $f[2];
			my $ccmdOutput= `ec2-describe-volumes $volID`;
			
			#print "\n\ndescribe-volume output\n$ccmdOutput";
			# TAG	volume	vol-4b5dcc30	filesystem	galaxyTools
			my @ffields = split ("\n",$ccmdOutput);
			foreach my $ll (@ffields) {
				if (($ll =~ /^TAG/) && ($ll =~ /filesystem/) ){
					my @ff = split("\t",$ll);
					my $label = $ff[4];
					if ($label =~ /galaxyTools/) {
						#print "\n\nQQQQ galaxy tools ";
						$mounted{"galaxyTools"} = 1;
					} elsif ($label =~ /galaxyData/) {
						#print "\n\nQQQQ galaxy data";
						$mounted{"galaxyData"} = 1;
					} elsif ($label =~ /galaxyIndices/) {
						#print "\n\nQQQQ galaxy indices";
						$mounted{"galaxyIndices"} = 1;
					}
				}
			}
		}
	}
	print "\n\nCloudman\t$hostName/cloud";
	print "\n\nlogin\tssh -i KEY ubuntu\@" . $hostName;
	print "\n";
	while (my ($k,$v) = each (%mounted)) {
		if ($v == 1) {
			print "\n'$k' mounted ";
		} else {
			print "\n'$k' not mounted.  Please mount this volume manually.";
		}
	}
	print "\n";
}

sub getGalaxyDefaultVolumes {
	my $clusterName = shift;

	my %galaxyVolumes = ();
	my $cmdOutput = `ec2-describe-volumes`;

	my @fields = split ("\n",$cmdOutput);
	foreach my $l (@fields) {
		# TAG	volume	vol-fa5dcc81	clusterName	modencode_galaxy_cluster
		if (($l =~ /^TAG/) && ($l =~ /clusterName/) && ($l =~ /$clusterName/)){
			my @f = split("\t",$l);
			print "\nvolumes $l";
		}
	}
}
sub getInstanceID {
	my $clusterName = shift;
	my $instanceID = "";

	my $cmdOutput = `ec2-describe-instances`;

	my @fields = split ("\n",$cmdOutput);
	foreach my $l (@fields) {
		# TAG	instance	i-c2b612b8	clusterName	modencode_galaxy_cluster
		if (($l =~ /^TAG/) && ($l =~ /clusterName/) && ($l =~ /$clusterName/)){
			my @f = split("\t",$l);
			$instanceID = $f[2];
			last;
		}
	}
	if (length($instanceID) == 0) {
		print "\n\nThere is no Galaxy instance running on Amazon!\n\n";
		exit (0);
	} else {
		return $instanceID;
	}
}



sub getGalaxyClusterName {

	my $dataFile = shift;
	my $line;
	my $clusterName = "";

	open(GALAXY_DATA,$dataFile) or die "\nERROR: Can't open '$dataFile'\n\n";
	while (<GALAXY_DATA>) {
		$line = $_;
		if ($line =~ m/cluster_name: (.*)/) {
			$clusterName = $1;
			last;
		}
	}
	close (GALAXY_DATA); 
	return $clusterName;
}
