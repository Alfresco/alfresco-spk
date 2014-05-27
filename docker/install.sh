#Installing docker, unzip and packer
sudo apt-get  -qqy update
sudo apt-get  -qqy install docker.io
sudo apt-get  -qqy install unzip
ln -sf /usr/bin/docker.io /usr/local/bin/docker
wget https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
sudo mkdir -p /opt/packer; sudo unzip 0.6.0_linux_amd64.zip -d /opt/packer

#Add packer bins in PATH
sudo touch /etc/profile.d/packer-path.sh
sudo bash -c 'echo export PATH=/opt/packer:$PATH > /etc/profile.d/packer-path.sh'

