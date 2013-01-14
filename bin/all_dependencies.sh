#!/bin/bash

# Purpose: Deploy macs2 and spp
# Date   : January, 2013
# Author : Fei-Yang Jen

#Global
#====================
hostname=`hostname`


#Check if the host is master/computing node
#==========================================
function check_node ( )
{
	if [[ "$Node_Type" == "" ]]; then
		export Node_Type="(Computing_Node)"	
	fi
}



#Function Call
#=====================

check_node

#Install macs2
/mnt/galaxyData/tmp/macs2_deploy.sh

#Install spp
rm -rf /usr/local/lib/R/site-library/00LOCK
echo -e "$hostname $Node_Type:\n   -Installing spp. It may take a few minutes ..."
echo ""
#use /dev/null to suppress the creation of the .Rout file.
R CMD BATCH /mnt/galaxyData/tmp/spp_deploy.R /dev/null
echo -e "$hostname $Node_Type:\n   -Installation of spp completed ... "
echo ""