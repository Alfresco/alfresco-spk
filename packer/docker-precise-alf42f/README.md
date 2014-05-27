Docker
---

### Docker Images

"image": "pandrew/ubuntu-lts",
stackbrew/ubuntu:precise
stackbrew/ubuntu:raring
"image": "ubuntu/13.10",
"image": "stackbrew/ubuntu:raring",
            
### Install

```
brew install boot2init
brew install docker
boot2docker up
boot2docker init #Starts the docker daemon
export DOCKER_HOST=tcp://localhost:4243 #Identifies the docker server; must be done on the same shell where the `packer' command is executed
```

For simplicity, open VirtualBox and add a new Network interface that is bridged to one of your host network interfaces.

Due to a [docker issue](https://github.com/mitchellh/packer/issues/901), it is necessary to do the following activities on the boot2docker vm
```
boot2docker ssh (pwd is `tcuser`)
tce-load -w -i sshfs-fuse.tcz bash.tcz
sudo bash -c 'echo user_allow_other > /etc/fuse.conf'
mkdir /var/folders
sshfs -o allow_root,uid=1000,gid=100 mau@192.168.1.23:/var/folders /var/folders
```
```192.168.1.23``` is my Host Private IP and ```mau``` the user on the Host machine

For more info on Docker installation ckeck the [Docker docs](http://docs.docker.io/installation/)

### Running Alfresco MySQL Container
```docker run -d -p 3306:3306 -e MYSQL_PASS="alfresco" tutum/mysql```

### Debugging Alfresco MySQL Container
```docker run -i -t -e MYSQL_PASS="alfresco" tutum/mysql bash```

### Running Alfresco Allinone Container
```packer build precise-alf42f.json```