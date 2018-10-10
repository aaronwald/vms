# http://vstone.eu/reducing-vagrant-box-size/

echo 'Cleanup source'
sudo rm -rf /tmp/bits
sudo rm -rf /opt/llvm
sudo rm -rf /opt/cmake-build
sudo rm -rf /opt/cmake-3.12.1
sudo rm -rf /opt/cmake-3.12.1.tar.gz
sudo rm -rf /opt/clang-build
sudo rm -rf /opt/git*
sudo rm -rf /opt/spd*

echo 'Cleanup yum'
sudo yum clean all
sudo rm -rf /var/cache/yum

echo 'Cleanup bash history'
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f /home/vagrant/.bash_history ] && rm /home/vagrant/.bash_history
 
echo 'Cleanup log files'
find /var/log -type f | while read f; do echo -ne '' > $f; done;
 
echo 'Whiteout root'
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`; 
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;
 
