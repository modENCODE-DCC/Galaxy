modENCODE Galaxy - Galaxy
=========================

Scripts
-------
**enablemacs2.pl** - uses sungrid engine to install python 2.7 across the cluster nodes
                     i.e. bin/enablemacs2.pl [-f]
        **deploymacs2.sh** - subscript used by enablemacs2 to deploy python 2.7

**enablespp.pl** - uses sungrid engine to install several R libraries and spp library across cluster nodes
                   i.e. bin/enablespp.pl [-f]
        **deployspp.R** - subscript used by enablespp to deploy R libraries
        **spp_1.10.1.tar.gz** - package containing spp phantom peaks library

**modENCODE_galaxy_config.pl** - used to copy the modENCODE tools into galaxy and set up dependencies
                                 i.e. bin/modENCODE_galaxy_config.pl modENCODE_DCC
        **modENCODE_galaxy_restart.pl** - subscript used to restart galaxy services
        **modENCODE_galaxy_start.pl** - subscript used to start galaxy services
        **modENCODE_galaxy_stop.pl** - subscript used to stop galaxy services

**modENCODE_galaxy_create.pl** - used in conjunction with config.txt to launch a customizable galaxy instance
                                 i.e. bin/modENCODE_galaxy_create.pl config.txt
        **modENCODE_galaxy_namevolumes.pl** - subscript used to name volumes attached to an amazon galaxy instance


Tools
-----
**bamedit** - merging, splitting, filtering, and QC of BAM files

**faceted_browser** - retrieve fastq files from the modENCODE ftp website

**idr** - consistency analysis on a pair of Peak files
        **idr-plot** - plot consistency analysis on idr output files

**macs** - model-based analysis of ChIP-Seq with peak.xls (1.4.1)
        **mac2npk** - converts macs output peak file to ENCODE narrowPeak format

**macs2** - model-based analysis of ChIP-Seq (2.0.10.2)

**peakranger** - multi-purpose, ultrafast ChIP-Seq peak caller

**spp** - cross-correlation analysis package
