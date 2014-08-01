Creating a Packer box
---
Create a host-only network interface for VirtualBox (unless ```ifconfig -a``` already lists ```vboxnet0```)
```
VBoxManage hostonlyif create >/dev/null 2>&1
```

Now assign an IP to this interface with a subnet that doesn't conflict with your home ones (avoid ```192.168.0.x```), for example ```192.168.23.x```
```
vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.23.1 --netmask 255.255.255.0
```

Edit file ```alfresco-boxes/packer/precise-alf421.json``` to choose an IP that can be bridged to one of your host Network Interfaces:
```
{
  "type": "shell",
  "execute_command": "echo 'vagrant' | sudo -S sh '{{ .Path }}'",
  "inline": ["/tmp/static-ip.sh 192.168.23.223 192.168.23.1 255.255.255.0"]
}
```

You also need to set your access credentials (that can be requested by Alfresco Customers via the Alfresco Support Portal) to [artifacts.alfresco.com](https://artifacts.alfresco.com) by editing [packer/vbox-precise-alf421/data_bags/maven_repos/private.json](https://github.com/maoo/alfresco-boxes/blob/master/common/data_bags/maven_repos/private.json)
```
{
  "id":"private",
  "url": "https://artifacts.alfresco.com/nexus/content/groups/private",
  "username":"your_user",
  "password":"{your_enc_password}"
}
```

You can optionally use your Maven encryped password and set your Maven Master password in ```precise-alf421.json```:
```
"maven": {
  "master_password":"{your_mvn_master_password}"
}
```

If you don't have credentials to artifacts.alfresco.com you can test it using the Community edition: change [alfresco-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer/precise-alf421.json#L73) ```version``` attribute to ```5.0.a```

To generate the box:
```
cd alfresco-boxes/packer
packer build -only virtualbox-iso precise-alf421.json
```
This will create a ```output-virtualbox-iso/<box-name>.ovf``` and ```output-virtualbox-iso/<box-name>.vdmk```, ready to be imported into VirtualBox.

The user/password to login is vagrant/vagrant
You can also create a Vagrant box by adding a Packer post-processor in [alfresco-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer/precise-alf421.json#L168)

Uploading AMI to AWS
---
```
cd alfresco-boxes/packer/vbox-precise-421
packer build -only amazon-ebs -var 'aws_access_key=YOUR ACCESS KEY' -var 'aws_secret_key=YOUR SECRET KEY' alfresco-allinone.json
```
The AMI is based on an existing Ubuntu 12.04 AMI ([ami-de0d9eb7](http://thecloudmarket.com/image/ami-de0d9eb7--ubuntu-images-ebs-ubuntu-precise-12-04-amd64-server-20130222))

Running Packer VM on Vagrant
---
If you want to create a VM with Packer and then run it with Packer, you can use  [this Vagrantfile](https://github.com/maoo/alfresco-boxes/tree/master/packer/Vagrantfile).

Simply run ```vagrant up``` from the ```packer``` folder.
