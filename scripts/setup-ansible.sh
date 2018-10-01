# Need to install local ansible before we can run ansible
sudo yum install -y epel-release
sudo yum install -y gcc python-pip python-devel libffi-devel openssl-devel
sudo pip install setuptools --upgrade
sudo pip install --upgrade pip
sudo yum -y install ansible
