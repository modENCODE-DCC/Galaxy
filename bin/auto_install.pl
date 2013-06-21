#!/usr/bin/perl -w 
use strict; 
use File::Basename; 

# Purpose : This script will help you patch/install latest Galaxy. And prepare 
#           other necessary installations and files for using modENCODE DCC.                                 
# Date    : January, 2013                                       
# Author  : Fei-Yang Jen                                           

# copy itself to user home dir and run it from there 
my $base=basename( $0 ) ; 
if (! -f "$ENV{'HOME'}/$base" ) { 
	system("cp $0 $ENV{'HOME'}") ; 
	system("$ENV{'HOME'}/$base") ; 
} 

# Global
# ==========================================================
my $gitrepo="/root/Galaxy/.git";
my $galaxy="/root/Galaxy";
my $dir="/mnt/galaxyTools/galaxy-central";
my $filename="DevNewsBriefs";
my $db_version="";
my $version="";

#Get galaxy_version and db_version
#=======================================
sub get_version ( )
{
    $db_version=`sh manage_db.sh db_version`;
    $version=`sh manage_db.sh version`;
}

#It will print the galaxy_version and db_version
#================================================
sub print_version ( )
{
    print "   - Code_version: $version\n";
    print "   - DB_version: $db_version\n";
}

#Restart Galaxy
#========================================
sub Restart ( )
{
    system("~/Galaxy/bin/modENCODE_galaxy_restart.pl");
    print "\n";
}

#Update/Restart DB
#============================================================
sub Update_DB ( )
{
    #Change directory to directory /mnt/galaxyTools/galaxy-central
    #==============================================================
    if (-d $dir ) { 
        print "Changing to dir: $dir ....\n";
        chdir($dir) ;  
    } else { 
        print "The dir: $dir does not exit ....\n"; 
        exit 1;
    } 

    #Pre-fetch the new dev release webpage from galaxyproject
    #========================================================
    #print "Fetching files ....."
    #wget -nv http://wiki.galaxyproject.org/DevNewsBriefs || { print "Error: The DevNewsBriefs link might need to be updated in the script and make sure you are connected to Internet"; exit 1;}
    #print -e "Done .....\n"

    #Process the pre-fetched webpage to obtain latest patch number
    #==============================================================
    
    #print "Fetching latest patch number ...."
    #upgrade=`grep -o -m 1 "hg update .*</pre>" $filename | sed 's/.\{6\}$//'` || exit 1
    #print -e "Done ....\n"

    print "Current version before update:";
    &get_version();
    &print_version();
    if ($version == $db_version) { 
        print "Upgrade has been initiated  ....\n";
        system("sudo -u galaxy hg pull\n"); 
        system("sudo -u galaxy hg checkout stable\n"); 
        system("sudo -u galaxy hg update stable\n"); 
        &get_version(); 
        #sudo -u galaxy $upgrade || exit 1
        #rm -f $filename || { print "Error: Cannot remove the file: $filename"; exit 1;}

        if ($version < $db_version) { 
            system("sh manage_db.sh upgrade\n"); 
            &Restart(); 
            &get_version(); 
            print "Upgrade has completed ....\n";
            print "Current version after update:\n";
            &print_version() ; 
        } elsif ($version == $db_version) { 
            print "Current version is up-to-date ... skip the update ...\n" ; 
            &print_version() ; 
	} else { 
            &get_version() ;
	    select(STDERR) ;  
            &print_version() ;
	    select(STDOUT); 
            print "ERROR: Failed to upgrade galaxy to latest version.\n    - Please contact: modENCODE DCC at help\@modencode.org\n";
            exit 1; 
        } 
    } elsif ($version > $db_version) { 
        system("sh manage_db.sh upgrade") ; 
        &Restart();
        &get_version();
        print "Upgrade has completed ....\n";
        print "Current version after update:\n";
        &print_version();
    }else { 
        &get_version(); 
	select(STDERR); 
        &print_version() ;
	select(STDOUT); 
        print "ERROR: Failed to upgrade galaxy to latest version.\n    - Please contact: modENCODE DCC at help\@modencode.org\n";
        exit 1; 
    } 
    

}

sub Check_Git ( )
{
    #Change directory to home directory to install modENCODE-DCC 
    #And check for the latest version of the source code
    #============================================================
    chdir() ; 
    if (-d "$galaxy") { 
        print ""; 
        print "Galaxy has been found ...\n";
   	chdir() ; 
        print "Checking updates ...\n";
        system("git pull") ; 
        if ($gitrepo and $? == 0) {
            print "Galaxy has been updated ...\n";
	    chdir() ;             
        } else { 
            print "ERROR/Missing file(s) ... removing original files ... \n";
            chdir(); 
	    system("rm -rf Galaxy"); 
            print "Reinstalling Galaxy ...\n";
            system("git clone https://github.com/modENCODE-DCC/Galaxy.git") == 0 or die  "Error: Unable to download modENCODE-DCC. Make sure git is installed and have access to Internet" ; 
        } 
    } else { 
        system("git clone https://github.com/modENCODE-DCC/Galaxy.git") == 0 or die "Error: Unable to download modENCODE-DCC. Make sure git is installed and have access to Internet" ; 
    }
}



#Function Calls
#===============================
&Update_DB;
&Check_Git;

chdir("$ENV{'HOME'}/Galaxy"); 
print "\n"; 
print "bin/modENCODE_galaxy_config.pl does the following:\n";
print "  - updates /mnt/galaxyTools/galaxy-central/universe_wsgi.ini configurations\n";
print "  - makes a backup of /mnt/galaxyTools/galaxy-central/tool_conf.xml\n";
print "  - updates /mnt/galaxyTools/galaxy-central/tool_conf.xml to include modENCODE DCC tools.  i.e., macs2, SPP, PeakRanger, IDR, etc.\n"; 
print "  - copies modENCODE DCC tools to /mnt/galaxyTools/galaxy-central/tools/\n";
print -e "  - restarts Galaxy\n"  ;
system("bin/modENCODE_galaxy_config.pl modENCODE_DCC_tools\n");
print "bin/enable.sh downloads and install all dependencies for modENCODE DCC tools.\n";
print "This process takes a few minutes to complete.  Wait until this process complete before going to the next step (Demo).\n";
system("bin/enable.sh") ; 
print "\n";


