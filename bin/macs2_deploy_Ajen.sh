#!/bin/bash

python_installed=`python -V 2>&1`
numpy_installed=`pip freeze | grep numpy`

if [ "$python_installed" == "Python 2.7.3" ]; 
then
    date=`date`
    echo "$date : Python 2.7.3 has been installed. Don't need to install python!" >> /var/log/macs2_deploy
else
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
    echo "$date : Python 2.7.3 is installed" >> /var/log/macs2_deploy
    #remove downloaded files
	cd
	rm -rf Python-2.7.3
fi

if [ "$numpy_installed" == "numpy==1.3.0" ]; 
then
	date=`date`
	echo "$date : python package - numpy 1.3.0 has been installed. Don't need to install numpy!" >> /var/log/macs2_deploy
else
	#install numpy
	git clone git://github.com/numpy/numpy.git numpy
	cd numpy
	python setup.py build
	python setup.py install
	date=`date`
	echo "$date : python package - numpy 1.3.0 is installed" >> /var/log/macs2_deploy	
fi



