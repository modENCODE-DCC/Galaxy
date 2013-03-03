#!/usr/bin/perl

use warnings;
use strict;


# default Galaxy version on Amazon 8140:8afb981f46c1

print "\n\n===========================================";
print "\nupdate Galaxy to get the latest copy ...";
system("cd /mnt/galaxyTools/galaxy-central; sudo -u galaxy hg pull; sudo -u galaxy hg checkout stable; sudo -u galaxy hg update stable");

# hg update release_2013.02.08 

print "\n\n===========================================";
print "\nupdate Galaxy database to latest version ...";
system("cd /mnt/galaxyTools/galaxy-central; sudo -u galaxy sh manage_db.sh upgrade");

print "\n\n";


