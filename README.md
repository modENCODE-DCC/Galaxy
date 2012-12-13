modENCODE-DCC: Galaxy
=========================

Scripts
-------

**enablemacs2.pl** - uses sungrid engine to install python 2.7 across the cluster nodes 

  >**deploymacs2.sh** - subscript used by enablemacs2 to deploy python 2.7

**enablespp.pl** - uses sungrid engine to install several R libraries and spp library across cluster nodes
  
  >**deployspp.R** - subscript used by enablespp to deploy R libraries
  
  >**spp_1.10.1.tar.gz** - package containing spp phantom peaks library

**modENCODE_galaxy_config.pl** - used to copy the modENCODE tools into galaxy and set up dependencies
  
  >**modENCODE_galaxy_restart.pl** - subscript used to restart galaxy services       
  
  >**modENCODE_galaxy_start.pl** - subscript used to start galaxy services
  
  >**modENCODE_galaxy_stop.pl** - subscript used to stop galaxy services

**modENCODE_galaxy_create.pl** - used in conjunction with config.txt to launch a customizable galaxy instance
  
  >**modENCODE_galaxy_namevolumes.pl** - subscript used to name volumes attached to an amazon galaxy instance


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


How to Launch Galaxy
--------------------
This section describes how to launch an instance of Galaxy step-by-step on Amazon Cloud. 
If you have any questions about this, please email help@modencode.org.

*NOTE: Steps 1 to 4 need only to be done once.  Afterward, you can go directly to Step 5 to launch your modENCODE Galaxy.*


**1.**  Create your Amazon EC2 account if you don't already have one.  Go to http://aws.amazon.com, click 
on 'Sign Up Now' and follow the instructions.  Keep your Amazon access and secret keys handy because 
you will need them in Step 3.  

**2.** Use git to clone or check out the latest copy of the modENCODE DCC Galaxy source code and tools.

    cd 
    git clone https://github.com/modENCODE-DCC/Galaxy.git
    cd Galaxy 
 

**3.** Edit 'env.sh' and set your JAVA_HOME, AWS_ACCESS_KEY, and AWS_SECRET_KEY environment variables. Set your environments by doing the following:

    . env.sh 

Test and make sure your environments are set correctly by doing the following:

    ec2-describe-regions

If you are able to run the above command then your environments are set correctly.  If you are not able to run the above command then see the below link on how to setup your EC2 API tools:

  >http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/SettingUp_CommandLine.html


**4.** Edit 'config.txt' to include the following configuration values for your modENCODE Galaxy instance
and CloudMan.  The Galaxy creation script bin/modENCODE_galaxy_create.pl in Step 5 uses values in this 
file to configure Galaxy and Cloudman.

  >**CLOUDMAN_PASSWORD:** galaxy_123
  >>Password to get into CloudMan console.  Default value is 'galaxy_123'. 

  >**KEY_PAIR:** YOUR_NAME_modENCODE_Galaxy_Key
  >>Keypair name to use to login to Galaxy.  Default value is 'YOUR_NAME_modENCODE_Galaxy_Key'.
  
  >**SECURITY_GROUP:** YOUR_NAME_modENCODE_Galaxy_Group
  >>Security group to be used by Galaxy.  Default value is 'YOUR_NAME_modENCODE_Galaxy_Group'.
  
  >**INSTANCE_NAME:** YOUR_NAME_modENCODE_Galaxy_Instance
  >>Label or name of your modENCODE Galaxy instance. Default value is 'YOUR_NAME_modENCODE_Galaxy_Instance'.
  
  >**CLUSTER_NAME:** YOUR_NAME_modENCODE_Galaxy_Cluster
  >>Galaxy cluster name.  Default value is 'YOUR_NAME_modENCODE_Galaxy_Cluster'.

  >**AMI:** ami-da58aab3
  >>Latest Galaxy AMI ID.  Default value is 'ami-da58aab3'.  For the latest AMI, see http://wiki.g2.bx.psu.edu/CloudMan/AWS/GettingStarted
  
  >**INSTANCE_TYPE:** m1.medium
  >>Amazon instance type.  Default value is 'm1.medium' ( recommended ). For other Amazon instance types, see http://aws.amazon.com/ec2/instance-types
  
  >**REGION:** us-east-1
  >>Amazon regioin to create modENCODE Galaxy instance in.  Default value is 'us-east-1'.
  
  >**AVAILABILITY_ZONE:** us-east-1a
  >>Amazon zone to create modENCODE Galaxy instance in.  Default value is 'us-east-1a'.

*NOTE: At the moment, Galaxy is supported only in US East region - see http://wiki.g2.bx.psu.edu/CloudMan.*

**5.** Launch an instance of modENCODE Galaxy using bin/modENCODE_galaxy_create.pl.  Run the script by itself to 
get its usage.  To launch modENCODE Galaxy instance with the configuration file created in Step 4, do the 
following:

    bin/modENCODE_galaxy_create.pl  config.txt 

Your modENCODE Galaxy instance may take a couple of minutes to start.  For your convenience, this script 
also outputs your Galaxy URL, your CloudMan console URL, and the ssh command to login to your modENCODE Galaxy.  
The Galaxy URL, CloudMan console URL, and the ssh command should look something like:

  >**Galaxy URL:** ec2-xx-xx-xx-xx.compute-1.amazonaws.com

  >**CloudMan console URL:** ec2-xx-xx-xx-xx.compute-1.amazonaws.com/cloud

  >**ssh command:** ssh -i KEY_FILE.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com


Once Galaxy has started, go to your CloudMan console to configure your modENCODE Galaxy instance. 
If you get an error message in your browser, then your CloudMan console is not ready yet.
Wait for a few seconds and reload your CloudMan console.  To login to your CloudMan console, leave the 
username field blank and use the password as indicated in 'config.txt' in Step 4.  

In your Initial Cluster Configuration dialog box, click on 'Show more start up options' and then select 
'Galaxy Cluster' and input your initial storage size ( say, 50 GB ).  Click on 'Choose CloudMan Platform'. 

*NOTE: increase your initial storage size if you are analyzing many data sets or large data sets.*


**6.** Check to make sure all Galaxy services have started.  Go to your CloudMan console and click on 'Admin' 
( top right of your browser ).  Scroll down to 'Services controls' and check to make sure status for Galaxy, 
PostgreSQL, SGE, and File systems are in 'Running' state.    These four services should start automatically.
Reload and wait until all of these services have started.  

*NOTE: These four services should start within 5 minutes.  If the services don't start after 5 minutes then there is something wrong!  Please contact help@modencode.org for help if this is the case.*
  
Once all four Galaxy services have started successfully, go to your Galaxy URL in a browser, and you should 
see: 

  >**(1)** the usual Galaxy tools in your Galaxy Tools panel on the left
  
  >**(2)** 'Welcome to Galaxy on the Cloud' logo in your working panel.


**7.** Before any analysis, you should add at least one more compute node to your Galaxy cluster.  Go to your CloudMan
console and click on 'Add nodes' to add additional compute nodes to your Galaxy cluster.  


**8.**  You are now ready to use Galaxy for your analysis.  


**9.** Finally, when you are done with all your analysis, terminate your Galaxy instance and its cluster.  Go to your 
CloudMan console and click on 'Terminate cluster', check off 'also delete this cluster', and click on 'Yes, power off'.
Your modENCODE Galaxy and its volumes should be terminated and delete shortly.  Use the AWS Management Console to make 
sure all nodes and volumes created by your modENCODE Galaxy are terminated and deleted.  
