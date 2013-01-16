#!/bin/bash

# Purpose     : Install Python and numpy on all cluster nodes  
# Date        : January, 2013                                 
# Author      : Ziru Zhou									  
# Modified by : Fei-Yang Jen 


#Global
#======================================
hostname=`hostname`

#Log directory
#======================================
function logfile ( )
{	echo "   - You can access log files by using the following commands:"
	echo "       1. ssh $hostname"
	echo "       2. cd /var/log/macs2_installation/"
	echo "       3. ls"
	echo "       4. vi filename" 
}



#Create a directory to store log files
#=======================================
function create_dir ( )
{
	if [[ -d "/var/log/macs2_installation" ]]; then
		echo -e "$hostname $Node_Type:\n   - Log file directory exists ... skip creating directory ... continuing the installation"
		logfile
	else
		sudo mkdir -p /var/log/macs2_installation
		echo -e "$hostname $Node_Type:\n   - Log file directory has been created."
		logfile
	fi	
}

#Install python dependencies
#=======================================
function python_install ( )
{
	cd 
    #get python
    #mkdir python2.7.3
    #cd python2.7.3
    wget http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2
    tar -xvf Python-2.7.3.tar.bz2
    cd Python-2.7.3
	#install python
	./configure
	make -j
	sudo make install
	#configure some python options
	sudo chmod ag+w /usr/local/lib/python2.7/site-packages
	sudo chmod ag+wx /usr/local/bin
	date=`date`
    echo "$date : Python 2.7.3 is installed" >> /var/log/macs2_installation/python_log
    #remove downloaded files
	cd
	rm -rf Python-2.7.3
}

#Install python package - numpy
#=======================================
function numpy_install ( )
{
	cd
	#install numpy
	git clone git://github.com/numpy/numpy.git numpy
	cd numpy
	python setup.py build
	python setup.py install
	date=`date`
	echo "$date : python package - numpy 1.3.0 is installed" >> /var/log/macs2_installation/numpy_log
	cd
	rm -rf numpy
}

#Resolve the correct hostname for master/computing nodes
#=======================================================
function resolve_host ( )
{
	if [[ "$hostname" == dom* ]];
	then
		hostname="$hostname.compute-1.internal"
	fi
}

#Function to log output for existence of the dependencies.
#It takes two arguments: The First parameter is used to 
#indicate which dependency has been installed; the second 
#parameter is the filename of the log.
#========================================================
function out_ext_dep ( )
{
	date=`date`
    echo -e "$hostname $Node_Type:\n   -$1 has been installed. Don't need to install python!"
    echo ""
    echo "$date : $1 has been installed. Don't need to install python!" >> /var/log/macs2_installation/"$2" #python_log, numpy_log
}

#Function to log output for unexistence of the dependencies
#It takes one argument, the dependence's name.
#==========================================================
function out_unext_dep ( )
{
	echo -e "$hostname $Node_Type:\n   -Installing $1 .... It may take a few minutes ..."
	echo ""
}




#Function calls
#====================================

resolve_host
create_dir

#Python: log installation outputs to logfile and also send them back to main console to update users
python_installed=`python -V 2>&1`
if [ "$python_installed" == "Python 2.7.3" ]; 
then
    out_ext_dep Python_2.7.3 python_log 
else
	out_unext_dep PYTHON
	#Call python_install function to install dependencies
	python_install >> /var/log/macs2_installation/python_install.log 2>> /var/log/macs2_installation/python_error.log 
fi

#Numpy: log installation outputs to logfile and also send them back to main concole to update users
python -c "import numpy" 2>/dev/null #check if numpy is installed or not! 
if [ $? -eq 0 ]; 
then
	out_ext_dep numpy_1.3.0 numpy_log
else
	out_unext_dep NUMPY
	#Call numpy_install function to install dependencies 
	numpy_install >> /var/log/macs2_installation/numpy_install.log 2>> /var/log/macs2_installation/numpy_error
fi

wait

echo -e "$hostname $Node_Type:\n   -Installation of macs2 completed ..."
echo ""



