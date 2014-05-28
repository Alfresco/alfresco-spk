#To install latest Docker version
sudo bash -c 'echo export PATH=/opt/packer:$PATH > /etc/profile.d/packer-path.sh'
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sudo sh -c "touch /etc/apt/sources.list.d/docker.list; echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"

#Installing docker, unzip and packer
sudo apt-get  -qqy update
sudo apt-get  -qqy install lxc-docker
sudo apt-get  -qqy install mysql-client
sudo service docker restart
sudo update-rc.d docker defaults
sudo chmod 777 /var/run/docker.sock

#Installing Packer
sudo apt-get  -qqy install unzip
wget https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
sudo mkdir -p /opt/packer; sudo unzip 0.6.0_linux_amd64.zip -d /opt/packer

#Add packer bins in PATH
sudo touch /etc/profile.d/packer-path.sh