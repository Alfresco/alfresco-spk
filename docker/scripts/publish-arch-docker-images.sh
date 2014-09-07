#Building/Importing `apache-lb` Docker Image
cd /alfboxes/docker/images/arch/apache-lb
/opt/packer/packer build apache-lb.json
docker import - maoo/apache-lb:latest < apache-lb.tar
rm *.tar
docker push maoo/apache-lb:latest

# Building/Importing `alfresco-repo` Docker Image
cd /alfboxes/docker/images/arch/alfresco-repo
/opt/packer/packer build alfresco-repo.json
docker import - maoo/alfresco-repo:latest < alfresco-repo.tar
rm *.tar
docker push maoo/alfresco-repo:latest

# Building/Importing `alfresco-share` Docker Image
cd /alfboxes/docker/images/arch/alfresco-share
/opt/packer/packer build alfresco-share.json
docker import - maoo/alfresco-share:latest < alfresco-share.tar
rm *.tar
docker push maoo/alfresco-share:latest

# Building/Importing `alfresco-solr` Docker Image
cd /alfboxes/docker/images/arch/alfresco-solr
/opt/packer/packer build alfresco-solr.json
docker import - maoo/alfresco-solr:latest < alfresco-solr.tar
rm *.tar
docker push maoo/alfresco-solr:latest

#Removing temporarily created containers
docker rm `docker ps --no-trunc -a -q`
