#Building/Importing/Publishing `alfresco-web-base` Alfresco Docker Image
cd /alfboxes/docker/images/base/alfresco-base
docker build -t maoo/alfresco-base:latest .

#Building/Importing/Publishing `alfresco-web-base` Alfresco Docker Image
cd /alfboxes/docker/images/base/alfresco-web-base
/opt/packer/packer build alfresco-web-base.json
docker import - maoo/alfresco-web-base < alfresco-web-base.tar
rm *.tar

#Building/Importing/Publishing `alfresco-repo-base` Docker Image
cd /alfboxes/docker/images/base/alfresco-repo-base
/opt/packer/packer build alfresco-repo-base.json
docker import - maoo/alfresco-repo-base < alfresco-repo-base.tar
rm *.tar
