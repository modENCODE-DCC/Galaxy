#!/usr/bin/perl 

#
# written by modENCODE DCC group
# please send your questions/comments to help@modencode.org 
#

use strict;
use warnings;
use File::Basename;

if ( @ARGV != 1 ) {
        print "\n";
        print "This script copies modENCODE DCC configuration files and tools over to Galaxy.  Please send questions/comments to help\@modencode.org.";
        print "\n\nusage: perl " . basename($0) . " [ DIR NAME ]  ";
	print "\n\tDIR_NAME\tname of directory contains configuration files for Galaxy. ";
	print "\n\n";
	exit 2;
}

my $INPUT_DIR = $ARGV[0];

my $GALAXY_CENTRAL = "/mnt/galaxyTools/galaxy-central";

print "\nmaking back up of $GALAXY_CENTRAL/tool_conf.xml ...";
system ("sudo cp -f $GALAXY_CENTRAL/tool_conf.xml $GALAXY_CENTRAL/tool_conf.xml.org");

print "\n\nreplacing $GALAXY_CENTRAL/tool_conf.xml with one from modENCODE DCC ...";
system ("sudo cp -f $INPUT_DIR/tool_conf.xml  $GALAXY_CENTRAL");

print "\n\nreplacing Galaxy logo with one from modENCODE DCC ...";
system ("sudo cp -f $INPUT_DIR/modencode_logo.png $GALAXY_CENTRAL/static/images/cloud_text.png");
system ("sudo cp -f $INPUT_DIR/welcome.html $GALAXY_CENTRAL/static/welcome.html");
system ("sudo chmod a+rx $GALAXY_CENTRAL/static/images/cloud_text.png");
system ("sudo chmod a+rx $GALAXY_CENTRAL/static/welcome.html");

print "\n\ncopying modENCODE DCC tools and wrappers to Galaxy ...";
my $DEST_DIR = "$GALAXY_CENTRAL/tools/$INPUT_DIR";
# if $DESTination dir not exists, create it 
if (! -e $DEST_DIR) {
	system ("sudo mkdir $DEST_DIR");
}

# ##################################
# config bamedit
system ("sudo cp -R $INPUT_DIR/bamedit $DEST_DIR");
# extract bamedit dependencies and move it to appropriate directory
# see http://wiki.g2.bx.psu.edu/Admin/Config/Tool%20Dependencies
my $BAMEDIT_DIR="/mnt/galaxyTools/tools/samtools";
# if BAMEDIT_DIR not exists, create it 
if (! -e $BAMEDIT_DIR) {
        system ("sudo mkdir $BAMEDIT_DIR");
}
# use backticks so outputs do not appear in console 
my $cmd_out_bamedit = `sudo tar xvf $INPUT_DIR/bamedit/0.1.12.tar`;
system ("sudo cp -R 0.1.12 $BAMEDIT_DIR/");
system ("sudo rm -rf 0.1.12");
if (! -e "$BAMEDIT_DIR/default") {
        system ("sudo ln -s $BAMEDIT_DIR/0.1.12 $BAMEDIT_DIR/default");
}

# ##################################
# config peakranger
system ("sudo cp -R $INPUT_DIR/peakranger $DEST_DIR");
# extract peakranger dependencies and move it to appropriate directory
# see http://wiki.g2.bx.psu.edu/Admin/Config/Tool%20Dependencies
my $PEAKRANGER_DIR="/mnt/galaxyTools/tools/peakranger";
# if PEAKRANGER_DIR not exists, create it 
if (! -e $PEAKRANGER_DIR) {
        system ("sudo mkdir $PEAKRANGER_DIR");
}
# use backticks so outputs do not appear in console 
my $cmd_out_ranger = `sudo tar xvf $INPUT_DIR/peakranger/1.16.tar`;
system ("sudo cp -R 1.16 $PEAKRANGER_DIR/");
system ("sudo rm -rf 1.16");
if (! -e "$PEAKRANGER_DIR/default") {
        system ("sudo ln -s $PEAKRANGER_DIR/1.16 $PEAKRANGER_DIR/default");
}

# ##################################
# config macs
system ("sudo cp -R $INPUT_DIR/macs $DEST_DIR");
# extract macs dependencies and move it to appropriate directory
# see http://wiki.g2.bx.psu.edu/Admin/Config/Tool%20Dependencies
my $MACS_DIR="/mnt/galaxyTools/tools/macs";
# if MACS_DIR not exists, create it 
if (! -e $MACS_DIR) {
	system ("sudo mkdir $MACS_DIR");
}
# use backticks so outputs do not appear in console 
my $cmd_out_macs = `sudo tar xvf $INPUT_DIR/macs/1.4.1.tar`; 
system ("sudo cp -R 1.4.1 $MACS_DIR/");
system ("sudo rm -rf 1.4.1");
if (! -e "$MACS_DIR/default") {
	system ("sudo ln -s $MACS_DIR/1.4.1 $MACS_DIR/default");
}

# ##################################
# config macs2
system ("sudo cp -R $INPUT_DIR/macs2 $DEST_DIR");
# extract macs2 dependencies and move it to appropriate directory
# see http://wiki.g2.bx.psu.edu/Admin/Config/Tool%20Dependencies
my $MACS2_DIR="/mnt/galaxyTools/tools/macs2";
# if MAC2_DIR not exists, create it 
if (! -e $MACS2_DIR) {
	system ("sudo mkdir $MACS2_DIR");
}
# use backticks so outputs do not appear in console 
my $cmd_out_macs2 = `sudo tar xvf $INPUT_DIR/macs2/2.0.10.2.tar`; 
system ("sudo cp -R 2.0.10.2 $MACS2_DIR/");
system ("sudo rm -rf 2.0.10.2");
if (! -e "$MACS2_DIR/default") {
	system ("sudo ln -s $MACS2_DIR/2.0.10.2 $MACS2_DIR/default");
}

# ##################################
# config SPP
system ("sudo cp -R $INPUT_DIR/spp $DEST_DIR");

# ##################################
# config IDR 
system ("sudo cp -R $INPUT_DIR/idr $DEST_DIR");

# ##################################
# config faceted browser
system ("sudo cp -R $INPUT_DIR/faceted_browser $DEST_DIR");

# ##################################
# change ownership and give rx permissions 
system ("sudo chown -R galaxy:galaxy $MACS2_DIR");
system ("sudo chmod -R a+rx $MACS2_DIR");

system ("sudo chown -R galaxy:galaxy $MACS_DIR");
system ("sudo chmod -R a+rx $MACS_DIR");

system ("sudo chown -R galaxy:galaxy $PEAKRANGER_DIR");
system ("sudo chmod -R a+rx $PEAKRANGER_DIR");

system ("sudo chown -R galaxy:galaxy $BAMEDIT_DIR");
system ("sudo chmod -R a+rx $BAMEDIT_DIR");

system ("sudo chown -R galaxy:galaxy $DEST_DIR");
system ("sudo chmod -R a+rx $DEST_DIR");

# finally, restart galaxy 
system("bin/modENCODE_galaxy_restart.pl");

print "\n\n";

