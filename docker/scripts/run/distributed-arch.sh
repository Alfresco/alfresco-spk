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

#Running Alfresco Enterprise Repository, only repository WAR  (repo1.alfresco-repo.demo.acme.com)
docker run --name bulk --dns $DNS_IP -d -p 8080:8080 -p 5701 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-repo:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"

#Alfresco needs some time to bootstrap db and contentstore
sleep 30

#Running Alfresco Enterprise Share  (share1.alfresco-share.demo.acme.com)
docker run --name share1 --dns $DNS_IP -d -p 8081:8080 -p 5701 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-share:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
docker run --name share2 --dns $DNS_IP -d -p 8082:8080 -p 5701 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-share:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"

#Running Alfresco Enterprise Solr  (solr1.alfresco-solr.demo.acme.com)
docker run --name solr1 --dns $DNS_IP -d -p 8083:8080 -p 5701 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-solr:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"

# Using HA Proxy balancer
docker run --name lb --dns $DNS_IP -d -v /alfboxes/common/haproxy:/haproxy-override -p 80:80 dockerfile/haproxy /bin/sh -c "chmod +x /haproxy-start; /haproxy-start ; tail -f /var/log/bootstrap.log"

# Debugging
# docker run --name lb --dns $DNS_IP -t -i -v /alfboxes/common/haproxy:/haproxy-override -p 80:80 dockerfile/haproxy /bin/bash
# docker run --name share3 --dns $DNS_IP -t -i -p 8084:8080 -p 5701 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-share:latest /bin/bash
