Alfresco Repository Enterprise
---

This image is based on [Alfresco Repo Base](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-repo-base) and installs Alfresco Repository application using [chef-alfresco](https://github.com/maoo/chef-alfresco) with the following configurations:
```
"json": {
  "alfresco": {
    "components" : ["repo"],
    "version"           : "4.2.3",
    "properties": {
      "db.host"               : "db.mysql.demo.acme.com",
      "dir.license.external"  : "/alflicense",
      "index.subsystem.name"  : "noindex"
    }
  },
  "tomcat" : {
    "base_version": 7
  }
}
```

The main purpose of this image is to provide an Alfresco Repository instance without any configuration for Share or Solr/Lucene, just a headless instance that can be used for bulk operations.

Host naming convention (`<name>.<type>.<domain>`) is enforced by [skydock](https://github.com/crosbymichael/skydock), an easy Docker Service discovery.

To run a container:
```
export DNS_IP=`ifconfig docker0| grep 'inet '| cut -d: -f2| awk '{ print $2}'`

docker run --name repo1 --dns $DNS_IP -d -p 8080:8080 -p 5701 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-repo:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
```
As you can see, you need to provide a valid Alfresco license file, in this example it's `/alfboxes/docker/license/alf42.lic`

Check the [distributed architecture script](https://github.com/maoo/alfresco-boxes/blob/master/docker/scripts/run/distributed-arch.sh) to see how to run it together with other containers.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/arch/alfresco-repo), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/alfresco-repo)
