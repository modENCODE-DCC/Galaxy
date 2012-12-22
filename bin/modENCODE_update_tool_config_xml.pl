#!/usr/bin/perl 

#
# written by modENCODE DCC group
# please send your questions/comments to help@modencode.org 
#

use strict;
use warnings;

# Galaxy tool config xml file 
my $toolConfigFile = " /mnt/galaxyTools/galaxy-central/tool_conf.xml";
# Galaxy tool config xml backup file 
my $toolConfigFileBackup = $toolConfigFile . ".bak";

# make a backup if there is no backup 
if (! -e $toolConfigFileBackup) {
	system ("sudo cp $toolConfigFile $toolConfigFileBackup");
}
# make a copy and put it in /tmp so we can read/write
system ("cp $toolConfigFile /tmp");

# open Galaxy tool config for writing 
open INFILE, "</tmp/tool_conf.xml",  or die $!;
open OUTFILE, ">/tmp/tool_conf.xml.out",  or die $!;
open TOOLFILE , "<../modENCODE_DCC_tools/modENCODE_DCC_tools.xml",  or die $!;
my @data = <TOOLFILE>;

while (<INFILE>) {
	print OUTFILE $_;
	if ($_ =~ /<toolbox>/) {
		print OUTFILE @data;
	}
}
close INFILE;
close OUTFILE;
close TOOLFILE;
system("sudo cp /tmp/tool_conf.xml.out $toolConfigFile");
