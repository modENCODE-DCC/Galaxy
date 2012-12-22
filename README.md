modENCODE-DCC: Galaxy
=========================

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


Tools
-----

**bamedit** - merging, splitting, filtering, and QC of BAM files

**faceted_browser** - retrieve fastq files from the modENCODE ftp website

**idr** - consistency analysis on a pair of Peak files

  >**idr-plot** - plot consistency analysis on idr output files

**macs** - model-based analysis of ChIP-Seq with peak.xls (1.4.1)
  
  >**mac2npk** - converts macs output peak file to ENCODE narrowPeak format

**macs2** - model-based analysis of ChIP-Seq (2.0.10.2)

**peakranger** - multi-purpose, ultrafast ChIP-Seq peak caller

**spp** - cross-correlation analysis package


