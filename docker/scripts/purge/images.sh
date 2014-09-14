docker kill `docker ps --no-trunc -a -q`
docker rm `docker ps --no-trunc -a -q`

docker rmi maoo/alfresco-allinone-community:latest
docker rmi maoo/alfresco-allinone-enterprise:latest
docker rmi maoo/apache-lb:latest
docker rmi maoo/alfresco-repo:latest
docker rmi maoo/alfresco-share:latest
docker rmi maoo/alfresco-solr:latest
