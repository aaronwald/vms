mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cat /tmp/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
