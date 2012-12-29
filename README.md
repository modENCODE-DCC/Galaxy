modENCODE-DCC: Galaxy
=========================

Documentations
-------------------
**docs/README.how.to.launch.Galaxy** - README file on how to launch an instance of Galaxy on Amazon
**docs/README.how.to.call.peaks** - README file on how to call peaks using tools put together by modENCODE DCC

Galaxy Tools
------------

**modENCODE_DCC_tools/bamedit** - merging, splitting, filtering, and QC of BAM files

**modENCODE_DCC_tools/faceted_browser** - retrieve fastq files from the modENCODE ftp website

**modENCODE_DCC_tools/idr** - consistency analysis on a pair of Peak files

  >**idr-plot** - plot consistency analysis on idr output files

**modENCODE_DCC_tools/macs** - model-based analysis of ChIP-Seq with peak.xls (1.4.1)
  
  >**mac2npk** - converts macs output peak file to ENCODE narrowPeak format

**modENCODE_DCC_tools/macs2** - model-based analysis of ChIP-Seq (2.0.10.2)

**modENCODE_DCC_tools/peakranger** - multi-purpose, ultrafast ChIP-Seq peak caller

**modENCODE_DCC_tools/spp** - cross-correlation analysis package


Scripts
-------

**bin/macs2_enable.pl** - uses Sun Grid Engine's qrsh to install python 2.7 across the cluster nodes 

  >**bin/macs2_deploy.sh** - subscript used by bin/macs2_enable.pl to deploy python 2.7

**bin/spp_enable.pl** - uses Sun Grid Engine's qrsh to install several R libraries and spp library across cluster nodes
  
  >**bin/spp_deploy.R** - subscript used by bin/spp_enable.pl to deploy R libraries
  
  >**spp_1.10.1.tar.gz** - package containing spp phantom peaks library

**bin/modENCODE_galaxy_config.pl** - used to copy the modENCODE tools into galaxy and set up dependencies
  
  >**bin/modENCODE_galaxy_restart.pl** - subscript used to restart galaxy services       
  
  >**bin/modENCODE_galaxy_start.pl** - subscript used to start galaxy services
  
  >**bin/modENCODE_galaxy_stop.pl** - subscript used to stop galaxy services

**bin/modENCODE_galaxy_create.pl** - used in conjunction with config.txt to launch a customizable galaxy instance
  
  >**bin/modENCODE_galaxy_namevolumes.pl** - subscript used to name volumes attached to an amazon galaxy instance
