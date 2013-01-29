modENCODE-DCC: Galaxy
=========================

This GitHub repository contains tools and scripts put together by members of the modENCODE DCC team:

 * Fei-Yang ( Arthur ) Jen
 * Quang Trinh
 * Marc Perry
 * Ellen Kephart
 * Sergio Contrino
 * Lincoln Stein
 
Alumini:
 * Ziru Zhou 
 * KarMing Chu
 

Please send your comments/questions to modENCODE DCC at help@modencode.org.


Documentations
-------------------
**docs/README.how.to.launch.Galaxy** - README file on how to launch an instance of Galaxy on Amazon

**docs/README.how.to.call.peaks** - README file on how to use the ENCODE/modENCODE uniform peak calling pipeline on Amazon Cloud

Galaxy Tools
------------

**modENCODE_DCC_tools/bamedit** - merging, splitting, filtering, and QC of BAM files

**modENCODE_DCC_tools/idr** - Reproducibility and automatic thresholding of ChIP-seq data, written by Anshul Kundaje ( https://sites.google.com/site/anshulkundaje/projects/idr )

  * **mac2npk** - converts macs output peak file to ENCODE narrowPeak format
  * **idr** - consistency analysis of peak files
  * **idr-plot** - plot consistency analysis on IDR output files
  * **IDR mailing list** - https://groups.google.com/group/idr-discuss 

**modENCODE_DCC_tools/macs** - model-based analysis of ChIP-Seq (1.4.1), written by Tao Liu
  
**modENCODE_DCC_tools/macs2** - model-based analysis of ChIP-Seq (2.0.10.2), written by Tao Liu ( https://github.com/taoliu/MACS )

**modENCODE_DCC_tools/peakranger** - multi-purpose, ultrafast ChIP-Seq peak caller, written by Xin Feng ( http://ranger.sourceforge.net/ )

**modENCODE_DCC_tools/spp** - cross-correlation analysis package ( http://code.google.com/p/phantompeakqualtools/ )


Other Scripts
-------------

**setup.py** - a wrapper script to call bin/auto_install.sh to install dependencies across cluster nodes automatically.
  
* **bin/auto_install.sh** - subscript used by setup.py to check version for both Galaxy and database, and update modENODE-DCC:Galaxy from GitHub   

* **bin/enable.sh** - uses Linux's ssh to install python 2.7, python packge - numpy, and spp across the cluster nodes 

* **bin/all_dependencies.sh** - lists out all the dependencies scripts and executes them one by one

* **bin/macs2_deploy.sh** - subscript used by bin/all_dependencies.sh to deploy python 2.7 and numpy
  
* **bin/spp_deploy.R** - subscript used by bin/all_dependencies.sh to deploy R libraries
  
* **spp_1.10.1.tar.gz** - package containing spp phantom peaks library

**bin/modENCODE_galaxy_config.pl** - used to copy the modENCODE tools into galaxy and set up dependencies
  
* **bin/modENCODE_galaxy_restart.pl** - subscript used to restart galaxy services       
  
* **bin/modENCODE_galaxy_start.pl** - subscript used to start galaxy services
  
* **bin/modENCODE_galaxy_stop.pl** - subscript used to stop galaxy services

**bin/modENCODE_galaxy_create.pl** - used in conjunction with config.txt to launch a customizable galaxy instance
  
* **bin/modENCODE_galaxy_namevolumes.pl** - subscript used to name volumes attached to an amazon galaxy instance

Reference
----------

**Getting Started with Galaxy CloudMan** - see http://wiki.galaxyproject.org/CloudMan/AWS/GettingStarted
