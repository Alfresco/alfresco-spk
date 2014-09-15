Alfresco Web Base
---

This image is based on [Alfresco  Base](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-base) and installs Apache Tomcat 7.0.26 (via apt-get) using [chef-alfresco](https://github.com/maoo/chef-alfresco) with the following configurations:
```
"json": {
    "alfresco": {
      "components": ["tomcat"]
    },
    "tomcat" : {
        "base_version": 7,
        "jvm_memory" : "-Xmx2500M -XX:MaxPermSize=512M"
    }
}
```

The main purpose of this image is to serve Chef-based installations of any J2EE Alfresco application (alfresco, solr, share), providing configurations for:
- `tomcat-users.xml` configuration, used for Alfresco-Solr SSL authentication
- `server.xml` configuration, used to configure SSL certificates on https endpoint (port 8443)
- `JAVA_OPTS` defines JMX hostname, defaulting to `node['alfresco']['default_hostname']`

This image is not meant to be used with `docker run`; use [alfresco-arch](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/arch) or [alfresco-allinone](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/allinone) images instead.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-web-base), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/alfresco-web-base)
