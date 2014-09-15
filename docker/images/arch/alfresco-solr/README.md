Alfresco Solr Enterprise
---

This image is based on [Alfresco Repo Base](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-repo-base) and installs Alfresco Repository and Solr applications using [chef-alfresco](https://github.com/maoo/chef-alfresco) with the following configurations:
```
"json": {
  "alfresco": {
    "components" : ["repo","solr"],
    "version"    : "4.2.3",
    "properties" : {
      "db.host"               : "db.mysql.demo.acme.com",
      "dir.license.external"  : "/alflicense"
    }
  },
  "tomcat" : {
    "base_version": 7
  }
}
```

The main purpose of this image is to provide an Alfresco Solr instance that tracks Alfresco Repository changes locally, while serving search queries coming from other containers.

Host naming convention (`<name>.<type>.<domain>`) is enforced by [skydock](https://github.com/crosbymichael/skydock), an easy Docker Service discovery.

To run a container:
```
export DNS_IP=`ifconfig docker0| grep 'inet '| cut -d: -f2| awk '{ print $2}'`

docker run --name solr1 --dns $DNS_IP -d -p 8082:8080 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-solr:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
```
As you can see, you need to provide a valid Alfresco license file, in this example it's `/alfboxes/docker/license/alf42.lic`

Check the [distributed architecture script](https://github.com/maoo/alfresco-boxes/blob/master/docker/scripts/run/distributed-arch.sh) to see how to run it together with other containers.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/arch/alfresco-solr), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/alfresco-solr)
