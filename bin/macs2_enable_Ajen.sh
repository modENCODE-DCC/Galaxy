#!/bin/bash


#Globals
#=========================================
NodesList=""
hostname=`hostname`


#Get the name of the computing nodes
#==========================================
function ComputingNodes ( )
{
	qhost | awk 'NR > 3' > trim_macs2.txt
 	NodesList=`cut -d ' ' --fields=1 trim_macs2.txt`
}


#Copy the installer over to the shared drive
#===========================================
function CopyInstaller ( )
{
	sudo cp bin/macs2_deploy.sh /mnt/galaxyData/tmp
}

#Execute the script on computing node
#===========================================
function Execute ( )
{
	if [[ "$1" == dom* ]]; 
	then
		1="$1.compute-1.internal"
		sudo ssh $1 -o "StrictHostKeyChecking no" "bash -s" < /mnt/galaxyData/tmp/123.sh
	elif [[ "$1" == "$hostname" ]]; then
		bash /mnt/galaxyData/tmp/123.sh
	else
		sudo ssh $1 -o "StrictHostKeyChecking no" "bash -s" < /mnt/galaxyData/tmp/123.sh
	fi 
}



#Function Calls
#===================================

ComputingNodes
CopyInstaller

#Calling Execution function
for nodes in $NodesList; do
	Execute ${nodes} &
done

wait

echo "Done ..."