Docker
---
This document explains
1. how to run a Docker Server using Vagrant (recommended) or boot2docker
2. walk through the build/import of an alfresco allinone docker container (using packer)
3. execution of a docker data-only container to store /var/lib/mysql and contentstore volumes
4. execution of 1 mysql docker contaner and 1 alfresco allinone container (previously built/imported)

If you're not familiar with Docker yet, this [Youtube video](https://www.youtube.com/watch?v=VeiUjkiqo9E) will explain you what it does and how to use it.

## Using Vagrant to run CoreOS (recommended)

* Setup your Alfresco Private Repository credentials; create ```common/data_bags/maven_repos/private.json```
```
{
  "id":"private",
  "url": "https://artifacts.alfresco.com/nexus/content/groups/private",
  "username":"<your_username>",
  "password":"<your_password>"
}
```
Note that this file is part of .gitignore

* Creating the Docker container
```
cd docker
vagrant up
vagrant ssh
```

* Building Alfresco Allinone Container
* Importing Alfresco Container
```
cd /alfboxes/docker
/opt/packer/packer build precise-alf422.json
docker import - maoo/alf-precise:latest < precise-alf422.tar
```

* Creating Data-only containers
* Running Alfresco MySQL Container
* Creating MySQL empty DB
* Running Alfresco Container

```
docker run -i -t --name alfresco_data -v /var/lib/mysql -v /var/lib/tomcat7/alf_data/contentstore busybox /bin/sh

# To map an existing folders to data volumes
#docker run -d --name alfresco_data -v $PWD/data/mysql:/var/lib/mysql -v $PWD/data/contentstore:/var/lib/tomcat7/alf_data/contentstore busybox /bin/sh

docker run -d -p 3306:3306 --volumes-from alfresco_data -e MYSQL_PASS="alfresco" tutum/mysql:latest

# Comment the following if previous line if existing /var/lib/mysql is provided
mysql -uadmin -h 172.17.0.2 -p
CREATE DATABASE IF NOT EXISTS alfresco CHARACTER SET utf8 COLLATE utf8_general_ci;

docker run -i -t -p 8080:8080 --volumes-from alfresco_data maoo/alf-precise bash
docker run -i -t -p 8081:8080 --volumes-from alfresco_data maoo/alf-precise bash
/etc/init.d/tomcat7 start #TODO this should start at boot time; fix it in the chef recipe
```

Using coreOS (WIP)
---

Run a MySQL DB instance (user admin, password alfresco); guest port 3306 is mapped to port 33306
```
docker run -d --name db -p 3306:3306 -e MYSQL_PASS="alfresco" tutum/mysql:latest
```

From the host machine, create an empty DB; skip this step if /var/lib/mysql is mounted (WIP)
```
mysql -u admin --port=33306 -h 127.0.0.1 -p
CREATE DATABASE alfresco CHARACTER SET utf8 COLLATE utf8_general_ci;
```

Run 2 repo instances, linked to the DB instance
```
docker run --name repo1 -d -p 8080:8080 --link db:db maoo/alf-precise /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
docker run --name repo2 -d -p 8081:8080 --link db:db maoo/alf-precise /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
```

Useful commands
```
# Remove all stopped Docker containers
docker rm `docker ps --no-trunc -a -q`
```


## (OSX - Alternative method) Using boot2docker

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
