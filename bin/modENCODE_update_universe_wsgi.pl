#!/usr/bin/perl -w

#
# written by modENCODE DCC group
# please send your questions/comments to help@modencode.org 
#
# update /mnt/galaxy/galaxy-app/universe_wsgi.ini to include tools from toolshed 
#

use strict;
use warnings;
use File::Basename;

# Galaxy tool config xml file 
my $universeWSGIFile = "/mnt/galaxy/galaxy-app/universe_wsgi.ini";

# backup 
my $universeWSGIFileBackup = $universeWSGIFile. ".bak";

# make a backup if there is no backup 
if (-e $universeWSGIFileBackup ) {
	print "\n$universeWSGIFileBackup exists ... skip backing up ";
} else {
	print "\nmaking a backup of $universeWSGIFile to $universeWSGIFileBackup";
	system ("sudo cp $universeWSGIFile $universeWSGIFileBackup");
}
# make a copy and put it in /tmp so we can read/write
system ("cp $universeWSGIFileBackup /tmp/" . basename($universeWSGIFile));

# open Galaxy tool config for writing 
open INFILE, "</tmp/" . basename($universeWSGIFile),  or die $!;
open OUTFILE, ">/tmp/" . basename($universeWSGIFile) . ".out",  or die $!;

while (<INFILE>) {
	if (($_ =~ /^tool_config_file/) && ($_ !~ /shed_tool_conf\.xml/)) {
		chomp($_);
		$_ = $_ . ",shed_tool_conf.xml\n";
	} 
	print OUTFILE $_;
}
close INFILE;
close OUTFILE;

print "\n\nupdating $universeWSGIFile ... ";
system("sudo cp /tmp/" . basename($universeWSGIFile) . ".out " . $universeWSGIFile);
print "done\n\n";
