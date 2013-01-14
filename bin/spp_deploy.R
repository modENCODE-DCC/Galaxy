
# Purpose     : Install/update R packages 
# Date        : January, 2013                                 
# Author      : Ziru Zhou									  
# Modified by : Fei-Yang Jen 

#Check bitops' version, and update the package if needed. 
x <- system("cat /usr/local/lib/R/site-library/bitops/DESCRIPTION | grep Version", intern = TRUE)
if(x != "Version: 1.0-5"){
        install.packages("bitops",dependencies=TRUE, repos="http://cran.us.r-project.org");
}else {
        cat("Version is correct");
}

#Check caTools' version, and update the package if needed.
y <- system("cat /usr/local/lib/R/site-library/caTools/DESCRIPTION | grep Version", intern = TRUE)
if(y != "Version: 1.14"){
        install.packages("caTools",dependencies=TRUE, repos="http://cran.us.r-project.org");
}else {
        cat("Version is correct");
}

#Check snow version, and update the package if needed.
z <- system("cat /usr/local/lib/R/site-library/snow/DESCRIPTION | grep Version", intern = TRUE)
if(z != "Version: 0.3-10"){
        install.packages("snow",dependencies=TRUE, repos="http://cran.us.r-project.org");
}else {
        cat("Version is correct");
}

#Install spp package. If the spp directory doesn't exist, return 1. 
w <- system("cat /usr/local/lib/R/site-library/spp/DESCRIPTION | grep Version || echo \"1\"", intern = TRUE)
if(w == "1"){
	install.packages('/mnt/galaxyData/tmp/spp_1.10.1.tar.gz',dependencies=TRUE)
}else {
        cat("Version is correct");
}