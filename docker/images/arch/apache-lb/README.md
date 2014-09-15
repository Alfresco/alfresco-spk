Apache Load Balancer
---

This image is based on [Alfresco Base](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-base) and installs Apache 2 (via apt-get) using [chef-alfresco](https://github.com/maoo/chef-alfresco) with the following configurations:
```
"json": {
  "alfresco" : {
    "components" : ["lb"]
  },
  "lb" : {
    "balancers" : {
      "alfresco" : [
        {
          "ipaddress" : "alf1.alfresco-allinone-enterprise.demo.acme.com",
          "route" : "repo1",
          "protocol" : "http",
          "port"  : "8080"
        },
        {
          "ipaddress" : "alf2.alfresco-allinone-enterprise.demo.acme.com",
          "route" : "repo2",
          "protocol" : "http",
          "port"  : "8080"

        }
      ],
      "share" : [
        {
          "ipaddress" : "alf1.alfresco-allinone-enterprise.demo.acme.com",
          "route" : "share1",
          "protocol" : "http",
          "port"  : "8080"
        },
        {
          "ipaddress" : "alf2.alfresco-allinone-enterprise.demo.acme.com",
          "route" : "share2",
          "protocol" : "http",
          "port"  : "8080"
        }
      ],
      "solr" : [
        {
          "ipaddress" : "alf1.alfresco-allinone-enterprise.demo.acme.com",
          "route" : "solr1",
          "protocol" : "http",
          "port"  : "8080"
        },
        {
          "ipaddress" : "alf2.alfresco-allinone-enterprise.demo.acme.com",
          "route" : "solr2",
          "protocol" : "http",
          "port"  : "8080"
        }
      ]
    }
  }
}
```

The main purpose of this image is to provide a Load Balancer for 2 Docker containers.

Containers are defined by:
- Name: `alf1` and `alf2`
- Type: `alfresco-allinone-enterprise`
- Domain: `demo.acme.com`

Host naming convention (`<name>.<type>.<domain>`) is enforced by [skydock](https://github.com/crosbymichael/skydock), an easy Docker Service discovery.

To run a container:
```
export DNS_IP=`ifconfig docker0| grep 'inet '| cut -d: -f2| awk '{ print $2}'`

docker run --name lb --dns $DNS_IP -d -p 80:80 maoo/apache-lb:latest /bin/sh -c "/etc/init.d/apache2 start ; sleep 1 ; tail -f /var/log/apache2/error.log"
```

Check the [balanced architecture script](https://github.com/maoo/alfresco-boxes/blob/master/docker/scripts/run/balanced-arch.sh) to see how to run it together with other containers.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/arch/apache-lb), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/apache-lb)
