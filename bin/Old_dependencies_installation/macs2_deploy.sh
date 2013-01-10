#!/bin/bash

cd 

#######################################
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

#######################################
#install numpy
git clone git://github.com/numpy/numpy.git numpy
cd numpy
python setup.py build
python setup.py install

#######################################
#remove downloaded files
cd
rm -rf python2.7.3

