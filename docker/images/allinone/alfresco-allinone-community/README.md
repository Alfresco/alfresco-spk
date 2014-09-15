Alfresco Allinone Community
---

This image is based on [Alfresco Repo Base](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-repo-base) and installs Alfresco Repository application using [chef-alfresco](https://github.com/maoo/chef-alfresco) with the following configurations:
```
"json": {
  "alfresco": {
    "components" : ["repo","share","solr"],
    "properties": {
      "db.host":"db.mysql.demo.acme.com"
    }
  },
  "tomcat" : {
    "base_version": 7
  }
}
```

The main purpose of this image is to provide a complete Alfresco Community 5.0.a installation, exposing Apache Tomcat on port `8080` with `/alfresco` and `/share` contexts available; Alfresco Solr is installed locally and tracks repository changes while serving search queries.

Host naming convention (`<name>.<type>.<domain>`) is enforced by [skydock](https://github.com/crosbymichael/skydock), an easy Docker Service discovery.

To run a container:
```
export DNS_IP=`ifconfig docker0| grep 'inet '| cut -d: -f2| awk '{ print $2}'`

docker run --name alf1 --dns $DNS_IP -d -p 8080:8080 --volumes-from data maoo/alfresco-allinone-community:latest /bin/sh -c "/etc/init.d/tomcat7 start ; sleep 1 ; tail -f /var/log/tomcat7/catalina.out"
```

Check the [community.sh script](https://github.com/maoo/alfresco-boxes/blob/master/docker/scripts/run/community.sh) to see how to run it together with other containers.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/allinone/alfresco-allinone-community), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/alfresco-allinone-community)
