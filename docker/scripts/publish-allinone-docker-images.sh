# Building/Importing `alfresco-allinone-community` Community Docker Image
cd /alfboxes/docker/images/allinone/alfresco-allinone-community
/opt/packer/packer build alfresco-allinone-community.json
docker import - maoo/alfresco-allinone-community:latest < alfresco-allinone-community.tar
rm *.tar
docker push maoo/alfresco-allinone-community:latest

# Building/Importing `alfresco-allinone` Enterprise Docker Image
cd /alfboxes/docker/images/allinone/alfresco-allinone-enterprise
/opt/packer/packer build alfresco-allinone-enterprise.json
docker import - maoo/alfresco-allinone-enterprise:latest < alfresco-allinone-enterprise.tar
rm *.tar
docker push maoo/alfresco-allinone-enterprise:latest

#Removing temporarily created containers
docker rm `docker ps --no-trunc -a -q`
