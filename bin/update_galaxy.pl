#!/usr/bin/perl

use warnings;
use strict;


# default Galaxy version on Amazon 8140:8afb981f46c1


system("cd /mnt/galaxyTools/galaxy-central; sudo -u galaxy hg pull; sudo -u galaxy hg checkout stable; sudo -u galaxy hg update stable");

#system("sudo -u galaxy hg pull"); 

#system("sudo -u galaxy hg checkout stable"); 

# hg update release_2013.02.08 

# Then to get all updates to the stable branch, you can:

# hg pull -b stable https://bitbucket.org/galaxy/galaxy-central

#system("sudo -u galaxy hg update stable");	


