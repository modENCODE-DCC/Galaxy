#/usr/bin/perl

# modENCODE_data_fetch.pl
# July 2012
# Gets data from modencode data site, given a list of download URLs
# Supposed to be run AFTER a list retrieving desired files from file browser

# Usage: perl modENCODE_data_fetch.pl inputFile output1 output1ID newFilePath

use strict;
use warnings;

# list of URLs in a text file
my $inputFile = $ARGV[0];

# first output file
my $output1 = $ARGV[1];

# ID number of these output entries
my $output1ID = $ARGV[2];

# determined file path 
my $newFilePath = $ARGV[3];

# counter for incrementing file names
my $counter = 1;

my $site = "data.modencode.org";
# my $site = "ec2-184-73-98-142.compute-1.amazonaws.com";

# open list of URL's file
open (URLLIST, $inputFile) or die ("Could not open file: $!");

my $PASS = "galaxy";

foreach my $line (<URLLIST>) 
{
	# gets rid of input record separators
	chomp $line;

	# check if line is not a comment
	# =~ signifies pattern matching
	# !~ is not matched (using regex)
	if ($line !~  /^#/) 
	{
		# select second column of file (the URL)
		my ($currentDir, $currentFile) = $line =~ /ftp\:\/\/$site(\/.*\/)(.*\.gz)/;

		# skip if not FASTQ file 
		next if $currentFile !~ /fastq/;

		# extract meaningful name
		my ($name) = $currentFile =~ /(.*)\.gz/;
		$name =~ s/\_/\-/g;

		# my $newFileAbPath = "$newFilePath/primary_$output1ID\_output$counter\_visible_fastq.gz";
		my $newFileAbPath = "$newFilePath/primary_$output1ID\_$name\_visible_fastq.gz";
		# file name is in format: "%s_%s_%s_%s_%s_%s" % ( 'primary', output1.id, name, 'visible', file_type, dbkey(build) )

		# command line call to download file at URL via ftp 
                `
                ftp -pn $site <<END
		quote USER anonymous
		quote PASS  
 
                binary
                cd $currentDir
                get $currentFile $newFileAbPath
                
                quit 
                END
                `;

		die $? if $?;

		# exception here possible: unzip file
		system("gzip -d $newFileAbPath") == 0 or die "Dead: $?";	

		$counter++;
	}
} 

close (URLLIST); 
