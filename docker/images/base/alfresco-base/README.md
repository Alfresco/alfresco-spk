Alfresco Base
---

This image is based on [Ubuntu 12.04]() and adds the following packages:
- wget
- ruby
- telnet
- sudo
- curl
- dnsutils
- iputils-ping
- telnet
- vim
- unzip
- less

The main purpose of this image is to serve Chef-based installations and provide debugging tools to check connectivity with other containers.

This image is not meant to be used with `docker run`; use [alfresco-arch](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/arch) or [alfresco-allinone](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/allinone) images instead.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-base), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/alfresco-base)
