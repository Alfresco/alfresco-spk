#Setting environment vars used by Docker runs
#Domain names are defined as <container_name>.<image_name>.$ENV.$DOMAIN_NAME
export ENV=demo
export DOMAIN_NAME=acme.com
export DNS_IP=`ifconfig docker0| grep 'inet '| cut -d: -f2| awk '{ print $2}'`

#Running Skydock (for DNS naming resolution)
docker run -d -p $DNS_IP:53:53/udp --name skydns crosbymichael/skydns -nameserver 8.8.8.8:53 -domain $DOMAIN_NAME
docker run -d -v /var/run/docker.sock:/docker.sock --name skydock crosbymichael/skydock -ttl 30 -environment $ENV -s /docker.sock -domain $DOMAIN_NAME -name skydns

sleep 3

#Running Data Container (data.ubuntu.demo.acme.com)
docker run --name data --dns $DNS_IP -v /var/lib/tomcat7/alf_data/contentstore -d ubuntu:12.04 /bin/sh -c "chmod -R 777 /var/lib/tomcat7/alf_data/contentstore ; watch top"

#Running DB (db.mysql.demo.acme.com)
docker run -d --name db --dns $DNS_IP -e MYSQL_DATABASE="alfresco" -e MYSQL_USER="alfresco" -e MYSQL_PASSWORD="alfresco" orchardup/mysql

sleep 3

#Running an Alfresco Community node (alf1.alf-precise.demo.acme.com)
docker run --name alf1 --dns $DNS_IP -d -p 8080:8080 --volumes-from data maoo/alfresco-allinone-community:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"

# For interactive server session
# docker run --name alf2 --dns $DNS_IP -t -i -p 8081:8080 --volumes-from data maoo/alfresco-allinone-community:latest /bin/bash
