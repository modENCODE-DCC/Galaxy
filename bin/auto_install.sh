#!/bin/bash


# Purpose : This script will help you patch/install latest Galaxy. And prepare 
#           other necessary installations and files for using modENCODE DCC.                                 
# Date    : January, 2013                                       
# Author  : Fei-Yang Jen                                           


#Global
#==========================================================
gitrepo="/root/Galaxy/.git"
galaxy="/root/Galaxy"
dir="/mnt/galaxyTools/galaxy-central"
filename="DevNewsBriefs"

#Get galaxy_version and db_version
#=======================================
function get_version ( )
{
    db_version=`sh manage_db.sh db_version`
    version=`sh manage_db.sh version`
}

#It will print the galaxy_version and db_version
#================================================
function print_version ( )
{
    echo "   - Galaxy_version: $version"
    echo "   - DB_version: $db_version"
}

#Update/Restart DB
#============================================================
function Update_DB ( )
{
    #Change directory to directory /mnt/galaxyTools/galaxy-central
    #==============================================================
    if [ -d "$dir" ];
    then
        echo "Changing to dir: $dir ...."
        echo ""
        cd $dir
    else
        echo "The dir: $dir does not exit ...." 
        echo ""
        exit 1
    fi

    #Pre-fetch the new dev release webpage from galaxyproject
    #========================================================
    echo "Fetching files ....."
    wget -nv http://wiki.galaxyproject.org/DevNewsBriefs || { echo "Error: The DevNewsBriefs link might need to be updated in the script and make sure you are connected to Internet"; exit 1;}
    echo "Done ....."
    echo ""

    #Process the pre-fetched webpage to obtain latest patch number
    #==============================================================
    echo "Fetching latest patch number ...."
    upgrade=`grep -o -m 1 "hg pull -u .*</pre>" $filename | sed 's/.\{6\}$//'` || exit 1
    echo "Done ...."
    echo ""
    echo "Wait till the upgade is completed then update your database ...."
    echo "Current version before update:"
    get_version
    print_version
    echo "Upgrade has been initiated  ...."
    sudo -u galaxy $upgrade || exit 1
    rm -f $filename || { echo "Error: Cannot remove the file: $filename"; exit 1;}

    #Check galaxy and db version
    #============================
    get_version

    if [[ "$version" -eq "db_version" || "$version" -gt "db_version" ]]; 
    then
        echo "Upgrade has completed ...."
        sh manage_db.sh upgrade
        print_version
    else
        print_version 1>&2
        echo -e "ERROR: Failed to upgrade galaxy to latest version.\n    - Please contact: modENCODE DCC at help@modencode.org"
        exit 1
    fi

}

function Check_Git ( )
{
    #Change directory to home directory to install modENCODE-DCC 
    #And check for the latest version of the source code
    #============================================================
    cd
    if [ -d "$galaxy" ]; then
        echo ""
        echo "Galaxy has been found ..."
        cd Galaxy
        echo "Checking updates ..."
        git pull
        if [[ -d "$gitrepo" && $? -eq 0 ]]; then
            echo "Galaxy has been updated ..."
            cd
        else
            echo "ERROR/Missing file(s) ... removing original files ... "
            cd
            rm -rf Galaxy
            echo "Reinstalling Galaxy ..."
            git clone https://github.com/modENCODE-DCC/Galaxy.git || { echo "Error: Unable to download modENCODE-DCC. Make sure git is installed and have access to Internet" ; exit 1; }
        fi
    else
        git clone https://github.com/modENCODE-DCC/Galaxy.git || { echo "Error: Unable to download modENCODE-DCC. Make sure git is installed and have access to Internet" ; exit 1; }
    fi
}

#Restart Galaxy
#========================================
function Restart ( )
{
    ~/Galaxy/bin/modENCODE_galaxy_restart.pl
    echo -e "\n"
}



#Function Calls
#===============================
Update_DB
Restart
Check_Git

cd ~/Galaxy
echo ""
echo "bin/modENCODE_galaxy_config.pl does the following:"
echo "  - updates /mnt/galaxyTools/galaxy-central/universe_wsgi.ini configurations"
echo "  - makes a backup of /mnt/galaxyTools/galaxy-central/tool_conf.xml"
echo "  - updates /mnt/galaxyTools/galaxy-central/tool_conf.xml to include modENCODE DCC tools.  i.e., macs2, SPP, PeakRanger, IDR, etc."  
echo "  - copies modENCODE DCC tools to /mnt/galaxyTools/galaxy-central/tools/"
echo "  - restarts Galaxy"  
echo ""
bin/modENCODE_galaxy_config.pl modENCODE_DCC_tools
echo "bin/enable.sh downloads and install all dependencies for modENCODE DCC tools."
echo "This process takes a few minutes to complete.  Wait until this process complete before going to the next step (Demo)."
bin/enable.sh
echo ""


