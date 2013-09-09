modENCODE-DCC: Galaxy
=========================

This GitHub repository contains tools and scripts put together by members of the modENCODE DCC team:

 * Quang Trinh
 * Marc Perry
 * Sergio Contrino
 * Lincoln Stein
 
Alumini:
 * Ellen Kephart
 * Ravpreet Setia 
 * Fei-Yang ( Arthur ) Jen
 * Ziru Zhou 
 * KarMing Chu
 
We would like to thank Bjoern Gruening (<bjoern.gruening@gmail.com>) for updating some of our scripts 
to take advantages of the newer Tool Shed features.  Please send your comments/questions to modENCODE DCC at help@modencode.org.


Documentations
-------------------

[README](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.launch.Galaxy) 
file on how to launch an instance of Galaxy on Amazon Cloud.

[README](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.call.peaks) 
file on how to use the ENCODE/modENCODE uniform processing/peak calling **pipeline** ( macs2, IDR, and IDR-plot ) in Galaxy on Amazon Cloud.

[README](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.use.workflows) 
file on how to use the ENCODE/modENCODE uniform processing/peak calling **workflows** ( macs2, IDR, and IDR-plot ) in Galaxy on Amazon Cloud.

README files on how to use [Amazon Cloud AMI](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.use.Amazon.AMI) or 
[Bionimbus Cloud](https://github.com/modENCODE-DCC/Galaxy/blob/master/docs/README.how.to.use.Bionimbus.AMI) to run the uniform processing/peak calling pipeline from the command line


Galaxy Tools 
------------

The tools listed below are also on [Galaxy Toolshed](http://toolshed.g2.bx.psu.edu/view/modencode-dcc)


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

[Getting Started with Galaxy CloudMan](http://wiki.galaxyproject.org/CloudMan/AWS/GettingStarted)
