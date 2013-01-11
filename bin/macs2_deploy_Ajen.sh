#!/bin/bash

hostname=`hostname`



#Create a directory to store log files
#=======================================
function create_dir ( )
{
	if [[ -d "/var/log/macs2_installation" ]]; then
		echo -e "$hostname:\n  - Log file directory exists ... skip creating dir ... continuing the installation"
		echo ""
	else
		sudo mkdir -p /var/log/macs2_installation
		echo -e "$hostname:	\n   -Log file directory has been created.\n   -You can access log files: /var/log/macs2_installation"
		echo ""
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





#Function calls
#====================================

create_dir

#Python: log installation outputs to logfile and also send them back to main console to update users
python_installed=`python -V 2>&1`
if [ "$python_installed" == "Python 2.7.3" ]; 
then
    date=`date`
    echo -e "$hostname:\n   -Python 2.7.3 has been installed. Don't need to install python!"
    echo ""
    echo "$date : Python 2.7.3 has been installed. Don't need to install python!" >> /var/log/macs2_installation/python_log
else
	echo -e "$hostname:\n   -Installing PYTHON .... It may take a few minutes ..."
	echo ""
	#Call python_install function to install dependencies
	python_install >> /var/log/macs2_installation/python_install.log 2>> /var/log/macs2_installation/python_error.log 
fi

#Numpy: log installation outputs to logfile and also send them back to main concole to update users
python -c "import numpy" 2>/dev/null #check if numpy is installed or not! 
if [ $? -eq 0 ]; 
then
	date=`date`
	echo -e "$hostname:\n   -python package - numpy 1.3.0 has been installed. Don't need to install numpy!"
	echo ""
	echo "$date : python package - numpy 1.3.0 has been installed. Don't need to install numpy!" >> /var/log/macs2_installation/numpy_log
else
	echo -e "$hostname:\n   -Installing NUMPY .... It may take a few minutes ..."
	echo ""
	#Call numpy_install function to install dependencies 
	numpy_install >> /var/log/macs2_installation/numpy_install.log 2>> /var/log/macs2_installation/numpy_error
fi

wait

echo -e "$hostname:\n   -Installation of macs2 completed ..."
echo ""



