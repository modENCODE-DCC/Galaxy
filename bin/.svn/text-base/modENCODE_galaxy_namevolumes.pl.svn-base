#!/usr/bin/perl

#global variables===============================
my $instanceid = $ARGV[0]; 

my $volid;
my $voltag;
my $clustername;
my $newtag;

#function calls===============================
print "Instance ID: $instanceid\n";
get_volumeid();

#function definitions=========================
#obtain the volume ids from the argument instance id, store them in global variables
sub get_volumeid
{
	#create array for output
	my @ec2cmd = `ec2-describe-instances $instanceid`;
	
	#iterate through the array to get the cluster name
	foreach my $i (@ec2cmd)
	{
		if(($i =~ /^TAG/) && ($i =~ /clusterName/)) 
		{
			my @line = split("\t", $i);
			$clustername = @line[4];
			chomp($clustername);
		}
	}

	#iterate through array looking for attached volumes and add appropriate tags
	foreach my $i (@ec2cmd)
	{
		if($i =~ /^BLOCKDEVICE/)
		{
			#separate the line by tabs and obtain the column with the volume id
			my @line = split("\t", $i);
			$volid = @line[2];
			$voltag = @line[1];
			
			if($voltag =~ "/dev/sda1")
			{
				#needs 2 extra commands since they were missing in initial code
				print "volumeid: $volid adding tag: ${clustername}_OS\n";
				$newtag = "${clustername}_OS";
				my $extra1 = `ec2-create-tags $volid --tag clusterName=$clustername`;
				my $extra2 = `ec2-create-tags $volid --tag filesystem=OS`;
			}
			elsif($voltag =~ "/dev/sdg1")
			{
				print "volumeid: $volid adding tag: ${clustername}_galaxyIndicies\n";
				$newtag = "${clustername}_galaxyIndicies";
			}
			elsif($voltag =~ "/dev/sdg2")
			{
				print "volumeid: $volid adding tag: ${clustername}_galaxyTools\n";
				$newtag = "${clustername}_galaxyTools";
			}
			elsif($voltag =~ "/dev/sdg3")
			{
				print "volumeid: $volid adding tag: ${clustername}_galaxyData\n";
				$newtag = "${clustername}_galaxyData";
			}
			my $addtagcmd = `ec2-create-tags $volid --tag Name=$newtag`;
		}
	}
}
