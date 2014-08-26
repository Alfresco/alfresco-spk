#Installing Packer
wget https://dl.bintray.com/mitchellh/packer/0.6.1_linux_amd64.zip
sudo mkdir -p /opt/packer; sudo unzip 0.6.1_linux_amd64.zip -d /opt/packer

#Download Docker images
docker pull tutum/mysql:latest
docker pull ubuntu:12.04
docker pull busybox:latest

# @TODO This part is still not working, needs to be executed manually, as documented in the README.md
# Problem is that the provisioning script gets interrupted

cd /alfboxes/docker
/opt/packer/packer build precise-alf422.json
docker import - maoo/alf-precise:latest < precise-alf422.tar
