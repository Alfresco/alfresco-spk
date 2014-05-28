Docker
---

## Using Vagrant (recommended)
```
cd docker
vagrant up
vagrant ssh
```

## Creating Data-only containers
```docker run -u 102 --name mysql-data -d -v $PWD/data/mysql:/var/lib/mysql stackbrew/busybox```

## Running Alfresco MySQL Container
```docker run -u 102 -d -p 3306:3306 --volumes-from mysql-data -e MYSQL_PASS="alfresco" tutum/mysql```

### Debugging Alfresco MySQL Container
```docker run -u 102 -i -t -e MYSQL_PASS="alfresco" --volumes-from mysql-data tutum/mysql bash```

## Building Alfresco Allinone Container
```packer build precise-alf42f.json```

### Importing/Running Alfresco Container
```
docker import - maoo/alf-precise:latest < precise-alf42f.tar
docker run -i -t -p 8080:8080 -v $PWD/data/contentstore:/var/lib/tomcat7/alf_data/contentstore maoo/alf-precise bash
/etc/init.d/tomcat7 start
```
(TODO - use supervisord to avoid the manual launch)

## (OSX, Optional) Installing and using boot2docker

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
