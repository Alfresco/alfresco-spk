#Download pre-defined Docker Images
docker pull ubuntu:12.04
docker pull orchardup/mysql:latest
docker pull crosbymichael/skydns:latest
docker pull crosbymichael/skydock:latest

# Built by build-base-images.sh
# docker pull maoo/alfresco-base:latest
# docker pull maoo/alfresco-web-base:latest
# docker pull maoo/alfresco-repo-base:latest

# Built by build-allinone-images.sh
docker pull maoo/alfresco-allinone-community:latest
docker pull maoo/alfresco-allinone-enterprise:latest

# Built by build-arch-images.sh
docker pull maoo/apache-lb:latest
docker pull maoo/alfresco-repo:latest
docker pull maoo/alfresco-share:latest
docker pull maoo/alfresco-solr:latest
