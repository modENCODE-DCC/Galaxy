

# default Galaxy version on Amazon 8140:8afb981f46c1

# sudo su galaxy 

cd /mnt/galaxyTools/galaxy-central

# hg pull 
hg checkout stable 

# hg update release_2013.02.08 

# Then to get all updates to the stable branch, you can:

# hg pull -b stable https://bitbucket.org/galaxy/galaxy-central

hg update stable 


