#!/usr/bin/perl

my $GALAXY_HOME = "/mnt/galaxy/galaxy-app";

print "\nrestarting Galaxy ... ";
my $cmdOutput =`sudo sh $GALAXY_HOME/run.sh --stop`;
system ("sudo chmod 755 $GALAXY_HOME/run.sh");
$cmdOutput = `sudo su -l galaxy -c \"$GALAXY_HOME/run.sh --reload --daemon\"`;

# wait for another 20 secs to make sure Galaxy restarted
sleep (20);
print "done ";
