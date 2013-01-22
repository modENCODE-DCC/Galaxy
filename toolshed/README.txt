
This directory stores Galaxy toolshed files for different packages put together by modDENCODE DCC group. Please send your questions and comments to modENCODE DCC at help@modencode.org.


Two folders are located in this directory: dependencies and tools. Due to the mechanism of installing package with or without dependencies through Galaxy Tool Shed, we have had this hierarchy structure to improve management in the future. As a result, these two folders contains different type of files and have different purposes. Dependencies folder stores necessary archived files that will be used during the installation of packages that require dependencies, and tools folder contains the files that are uploaded to Galaxy tool Shed for every users to download to their local Galaxy machines.     


A brief introduction of what type of files are located in dependencies folder and tools folder:

Dependencies Folder:
When navigate to the folder, you will see 5 subfolders. They are:
	1. bamedit
	2. macs
	3. macs2
	4. peakranger
	5. spp
Each folder contains one compressed file (.tar, .tar.gz, or .tar.bz2) which will be used later on during package installation through Galaxy Tool Shed. Those archived filed can be accessed/downloaded by typing the URLs:
For example,
	https://github.com/modENCODE-DCC/Galaxy/blob/b1/toolshed/dependencies/bamedit/samtoolspkg.tar?raw=true 
Adding "?raw=true" at the end telling GitHub server that you would like to download the specified files, and this is the way that we use to tell Galaxy Tool Shed where to grab the archived files from. 


