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
README file on how to launch an instance of Galaxy on Amazon - see [README.how.to.launch.Galaxy](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.launch.Galaxy)

README file on how to use the ENCODE/modENCODE uniform processing/peak calling pipeline ( macs2, IDR, and IDR-plot ) on Amazon Cloud - see [README.how.to.call.peaks](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.call.peaks)

README file on how to use the ENCODE/modENCODE uniform processing/peak calling workflow ( macs2, IDR, and IDR-plot ) on Amazon Cloud - see [README.how.to.use.workflows](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.use.workflows)


Galaxy Tools 
------------

The tools listed below are also on [Galaxy Toolshed](http://toolshed.g2.bx.psu.edu/)


**modENCODE_DCC_tools/bamedit** - merging, splitting, filtering, and QC of BAM files

**modENCODE_DCC_tools/idr** - Reproducibility and automatic thresholding of ChIP-seq data, written by Anshul Kundaje ( https://sites.google.com/site/anshulkundaje/projects/idr )

  * **mac2npk** - converts macs output peak file to ENCODE narrowPeak format
  * **idr** - consistency analysis of peak files
  * **idr-plot** - plot consistency analysis on IDR output files
  * **IDR Google discussion group** - https://groups.google.com/group/idr-discuss 

**modENCODE_DCC_tools/macs** - model-based analysis of ChIP-Seq (1.4.1), written by Tao Liu
  
**modENCODE_DCC_tools/macs2** - model-based analysis of ChIP-Seq (2.0.10.2), written by Tao Liu ( https://github.com/taoliu/MACS )

**modENCODE_DCC_tools/peakranger** - multi-purpose, ultrafast ChIP-Seq peak caller, written by Xin Feng ( http://ranger.sourceforge.net/ )

**modENCODE_DCC_tools/spp** - cross-correlation analysis package ( http://code.google.com/p/phantompeakqualtools/ )


Reference
----------

**Getting Started with Galaxy CloudMan** - see http://wiki.galaxyproject.org/CloudMan/AWS/GettingStarted
