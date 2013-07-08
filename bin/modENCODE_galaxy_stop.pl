#!/usr/bin/perl

my $GALAXY_HOME = "/mnt/galaxy/galaxy-app";

print "\n\nstopping Galaxy ... \n";
my $cmdOutput =`sudo sh $GALAXY_HOME/run.sh --stop`;

# wait for another 10 secs to make sure Galaxy has stopped
sleep (10);
print "done ";
