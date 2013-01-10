#!/bin/ban

hostname=`hostname`

#Install macs2
/mnt/galaxyData/tmp/macs2_deploy_Ajen.sh

#Install spp
rm -rf /usr/local/lib/R/site-library/00LOCK
echo "Installing spp on $hostname. It may take a few minutes ..."
R CMD BATCH /mnt/galaxyData/tmp/spp_deploy.R
echo "Installation of spp completed on $hostname ... "
echo ""

