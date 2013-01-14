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
echo "Upgrade has been initiated  ...."
sudo -u galaxy $upgrade || exit 1
echo "Upgrade has been completed ...."
echo ""
echo "IMPORTANT: Go to yourCloudManConsole and click on 'Admin'.  Scroll down and click on 'Update DB' to update your database schema." 
echo "Galaxy should restart automatically after database schema upgrade.  Make sure Galaxy is up and running."
echo "This process may take a few mintues to update and restart Galaxy."
rm -f $filename || { echo "Error: Cannot remove the file: $filename"; exit 1;}


#Prompt to make sure users have checked the status of the Cloudman before continuing
#===================================================================================
while true; do
  echo ""
  echo ""
  echo -n "    > Please make sure Galaxy is running and the database is updated before continuing [y/n]:"  
  read yn  
    case $yn in
      [Yy]* )
        #Change directory to home directory to install modENCODE-DCC 
        #And check for the latest version of the source code
        #============================================================
        cd
        if [ -d "$galaxy" ]; then
            echo "Galaxy has been found ..."
            echo "Checking updates ..."
            cd Galaxy
            if [ -d "$gitrepo" ]; then
                git pull
                echo "Galaxy has been updated ..."
                cd
            else
                echo "Missing file(s) ... removing original files ... "
                cd
                rm -rf Galaxy
                echo "Reinstalling Galaxy ..."
                git clone https://github.com/modENCODE-DCC/Galaxy.git || { echo "Error: Unable to download modENCODE-DCC. Make sure git is installed and have access to Internet" ; exit 1; }
            fi
        else
            git clone https://github.com/modENCODE-DCC/Galaxy.git || { echo "Error: Unable to download modENCODE-DCC. Make sure git is installed and have access to Internet" ; exit 1; }
        fi
        #Change directory to Galaxy directory and its subdirectory to execute necessary scripts
        #======================================================================================
        cd Galaxy
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
        break
        ;;
      [Nn]* ) 
        ;;
      * )
        echo ""
        echo "Invalid input .... Abort"
        exit 1
        ;;
    esac  
done

