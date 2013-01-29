
modENCODE DCC Scripts
------------------------

**setup.py** - a wrapper script to call bin/auto_install.sh to install dependencies across cluster nodes automatically.
  
* **bin/auto_install.sh** - subscript used by setup.py to check version for both Galaxy and database, and update modENODE-DCC:Galaxy from GitHub   

* **bin/enable.sh** - uses Linux's ssh to install python 2.7, python packge - numpy, and spp across the cluster nodes 

* **bin/all_dependencies.sh** - lists out all the dependencies scripts and executes them one by one

* **bin/macs2_deploy.sh** - subscript used by bin/all_dependencies.sh to deploy python 2.7 and numpy
  
* **bin/spp_deploy.R** - subscript used by bin/all_dependencies.sh to deploy R libraries
  
* **spp_1.10.1.tar.gz** - package containing spp phantom peaks library

**bin/modENCODE_galaxy_config.pl** - used to copy the modENCODE tools into galaxy and configure dependencies
  
* **bin/modENCODE_galaxy_restart.pl** - subscript used to restart galaxy services       
  
* **bin/modENCODE_galaxy_start.pl** - subscript used to start galaxy services
  
* **bin/modENCODE_galaxy_stop.pl** - subscript used to stop galaxy services

**bin/modENCODE_galaxy_create.pl** - used in conjunction with config.txt to launch a customizable galaxy instance
  
* **bin/modENCODE_galaxy_namevolumes.pl** - subscript used to name volumes attached to an amazon galaxy instance

