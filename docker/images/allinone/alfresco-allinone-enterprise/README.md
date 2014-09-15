Alfresco Allinone Enterprise
---

This image is based on [Alfresco Repo Base](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-repo-base) and installs Alfresco Repository application using [chef-alfresco](https://github.com/maoo/chef-alfresco) with the following configurations:
```
"json": {
  "alfresco": {
    "version"           : "4.2.3",
    "default_hostname"  : "lb.apache-lb.demo.acme.com",
    "default_port"      : "80",
    "components"        : ["repo","share","solr"],
    "properties" : {
      "db.host"               :"db.mysql.demo.acme.com",
      "dir.license.external"  : "/alflicense",
      "solr.host"             : "localhost"
    },
    "solrproperties": {
      "alfresco.host" : "localhost"
    }
  },
  "tomcat" : {
    "base_version": 7
  }
}
```

The main purpose of this image is to provide a complete Alfresco Enterprise 4.2.3 installation, exposing Apache Tomcat on port `8080` with `/alfresco` and `/share` contexts available; Alfresco Solr is installed locally and tracks repository changes while serving search queries; the image is cluster-ready (see below)

Host naming convention (`<name>.<type>.<domain>`) is enforced by [skydock](https://github.com/crosbymichael/skydock), an easy Docker Service discovery.

To run a container:
```
export DNS_IP=`ifconfig docker0| grep 'inet '| cut -d: -f2| awk '{ print $2}'`

docker run --name alf1 --dns $DNS_IP -d -p 8080:8080 -p 5701 -v /alfboxes/docker/license/alf42.lic:/alflicense/alf42.lic --volumes-from data maoo/alfresco-allinone-enterprise:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
```
As you can see, you need to provide a valid Alfresco license file, in this example it's `/alfboxes/docker/license/alf42.lic`

Check the [distributed architecture script](https://github.com/maoo/alfresco-boxes/blob/master/docker/scripts/run/balanced-arch.sh) to see how to run it together in a clustered environment.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/allinone/alfresco-allinone-enterprise), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/alfresco-allinone-enterprise)
