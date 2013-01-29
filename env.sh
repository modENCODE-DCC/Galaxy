
# set JAVA_HOME
export JAVA_HOME=your_JAVA_HOME_PATH

# set your AWS credentials 
export AWS_ACCESS_KEY=your_AWS_ACCESS_KEY_ID 
export AWS_SECRET_KEY=your_AWS_SECRET_KEY

############################################
# no changes are needed below this line
############################################

# set EC2_HOME and add $EC2_HOME/bin to $PATH
export EC2_HOME=./external_tools/ec2-api-tools-1.6.1.4
export PATH=$PATH:$EC2_HOME/bin

