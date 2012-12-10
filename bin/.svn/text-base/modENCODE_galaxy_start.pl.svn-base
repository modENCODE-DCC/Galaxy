#!/usr/bin/perl

my $GALAXY_HOME = "/mnt/galaxyTools/galaxy-central";

print "\n\nstarting Galaxy ... \n";
system ("sudo chmod 755 $GALAXY_HOME/run.sh");
$cmdOutput = `sudo su -l galaxy -c \"$GALAXY_HOME/run.sh --reload --daemon\"`;

# wait for another 10 secs to make sure Galaxy started
sleep (10);
print "done ";
