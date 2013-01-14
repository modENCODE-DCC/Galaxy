#!/bin/bash


# Purpose     : Install/update dependencies on all cluster nodes and servers.        
#             : These include,                                       
#             :        - Python, and its package numpy.           
#             :        - .R packages: bitops, caTools, and snow.  
# Date        : January, 2013                                 
# Author      : Ziru Zhou									  
# Modified by : Fei-Yang Jen                                   



#Globals
#=========================================
NodesList=""
hostname=`hostname`


function header ( )
{
	echo ""
	echo "#####################################################"
	echo "###                                               ###"
	echo "### The script will install/update dependencies   ###"
	echo "### on all the computing nodes and servers. This  ###"
	echo "### includes:                                     ###"
	echo "###   - Python, and its package numpy.            ###"
	echo "###   - .R packages: bitops, caTools, and snow.   ###"
	echo "### It will take a while to complete the process. ###"
	echo "### Have a cup of coffee then come back  = ) !!   ###"
	echo "###                                               ###"
	echo "#####################################################"
	echo ""
	sleep 3
}

#Get the name of the computing nodes
#==========================================
function ComputingNodes ( )
{
	qhost | awk 'NR > 3' > trim_macs2.txt
 	NodesList=`cut -d ' ' --fields=1 trim_macs2.txt`
}

#Remove tmp file
#=========================================
function Cleanup ( )
{
	sudo rm trim_macs2.txt
}

#Restart Galaxy
#========================================
function Restart ( )
{
	bin/modENCODE_galaxy_restart.pl
	echo -e "\n\n"
}

#Copy the installer over to the shared drive
#===========================================
function CopyInstaller ( )
{
	sudo cp bin/macs2_deploy.sh /mnt/galaxyData/tmp
	sudo cp bin/spp_deploy.R /mnt/galaxyData/tmp
	sudo cp bin/spp_1.10.1.tar.gz /mnt/galaxyData/tmp
	sudo cp bin/all_dependencies.sh /mnt/galaxyData/tmp
}


#Execute the script on computing node
#===========================================
function Execute ( )
{
	#process the nodes 
	if [[ "$1" == dom* ]]; 
	then
		#Set environment variable for master-node
		tmp_ip="$1.compute-1.internal"
		#echo "Installing dependencies on $1. It may take a few minutes ..."
		sudo ssh $tmp_ip -o "StrictHostKeyChecking no" "bash -s" < /mnt/galaxyData/tmp/all_dependencies.sh
	elif [[ "$1" == "$hostname" ]]; then
		#Set environment variable for master-node
		export Node_Type="(Master_Node)"
		#echo "Installing dependencies on $1. It may take a few minutes ..."
		bash /mnt/galaxyData/tmp/all_dependencies.sh
	else
		#Set environment variable for master-node
		#echo "Installing dependencies on $1. It may take a few minutes ..."
		sudo ssh $1 -o "StrictHostKeyChecking no" "bash -s" < /mnt/galaxyData/tmp/all_dependencies.sh
	fi 
}




#Function Calls
#============================================
header
ComputingNodes
CopyInstaller

#Calling Execution function. 
#All the dependencies will be installed on computing nodes at the same time.
for nodes in $NodesList; do
	Execute ${nodes} &
done

#Wait till the process to finish in parallel 
wait

echo -e "\n"
echo "Done: All the dependencies have been installed on computing nodes. You can start analizing your data ..."

Cleanup

Restart

echo ""
