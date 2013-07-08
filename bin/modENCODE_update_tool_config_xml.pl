#!/usr/bin/perl -w

#
# written by modENCODE DCC group
# please send your questions/comments to help@modencode.org 
#

use strict;
use warnings;
use File::Basename;

# Galaxy tool config xml file 
my $toolConfigFile = "/mnt/galaxy/galaxy-app/tool_conf.xml";
# Galaxy tool config xml backup file 
my $toolConfigFileBackup = $toolConfigFile . ".bak";

# make a backup if there is no backup 
if (-e $toolConfigFileBackup) {
	print "\n$toolConfigFileBackup exists ... skip backing up ";
} else {
	print "\nmaking a backup of $toolConfigFile to $toolConfigFileBackup";
	system ("sudo cp $toolConfigFile $toolConfigFileBackup");
}
# make a copy and put it in /tmp so we can read/write
system ("cp $toolConfigFileBackup /tmp/" . basename($toolConfigFile));

# open Galaxy tool config for writing 
open INFILE, "</tmp/" . basename($toolConfigFile),  or die $!;
open OUTFILE, ">/tmp/" . basename($toolConfigFile) . ".out",  or die $!;
open TOOLFILE , "<modENCODE_DCC_tools/modENCODE_DCC_tools.xml",  or die $!;
my @data = <TOOLFILE>;

while (<INFILE>) {
	print OUTFILE $_;
	if ($_ =~ /^\<toolbox\>/) {
		print OUTFILE @data;
	}
}
close INFILE;
close OUTFILE;
close TOOLFILE;

print "\n\nupdating $toolConfigFile ... ";
system("sudo cp /tmp/tool_conf.xml.out $toolConfigFile");
print "done\n";
