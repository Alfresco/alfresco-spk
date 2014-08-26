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

### Building/Importing Alfresco Allinone Container

```
cd /alfboxes/docker
/opt/packer/packer build precise-alf422.json
docker import - maoo/alf-precise:latest < precise-alf422.tar
```

### Setting up a data instance (keeps mysql data and contentstore)
```
docker run --name data -v /var/lib/tomcat7/alf_data/contentstore -v /var/lib/mysql -d busybox /bin/sh -c "chmod -R 777 /var/lib/tomcat7/alf_data/contentstore ; watch top"
```

### Setting up DB instance

* Run a MySQL DB instance (user admin, password alfresco); guest port 3306 is mapped to port 33306
```
docker run -d --name db -p 3306:3306 --volumes-from data -e MYSQL_PASS="alfresco" tutum/mysql:latest
```

* From the host machine, log into mysql (pwd is ```alfresco```) and create an empty DB
```
mysql -u admin --port=33306 -h 127.0.0.1 -p
CREATE DATABASE alfresco CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON alfresco.* TO 'alfresco' IDENTIFIED BY 'alfresco';
```

### Running a 2-nodes Alfresco Repository cluster (linked to db and data instances)
```
docker run --name repo1 -d -p 8080:8080 --link db:db --volumes-from data maoo/alf-precise /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
docker run --name repo2 -d -p 8081:8080 --link db:db --volumes-from data maoo/alf-precise /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
```

## Useful commands

```
# Remove all stopped Docker containers
docker rm `docker ps --no-trunc -a -q`

# Run an interactive Alfresco repo instance (for debugging purposes)
docker run --name repoX -t -i -p 18080:8080 --volumes-from data --link db:db maoo/alf-precise /bin/bash

```
