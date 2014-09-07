Docker
---
This procedure is based on the installation steps described in the [Alfresco Boxes README](https://github.com/maoo/alfresco-boxes)

If you're not familiar with Docker yet, this [Youtube video](https://www.youtube.com/watch?v=VeiUjkiqo9E) will explain you what it does and how to use it.

This tutorial will guide you through the installation of a Vagrant Box (running on VirtualBox) with [CoreOS](https://coreos.com) Linux distro installed and ready to run Docker commands

Host/CoreOS port mapping is configured as follows:
* Host Port 30080 mapped to CoreOS 80
* Host Port 33306 mapped to CoreOS 3306
* Host Port 38080 mapped to CoreOS 8080
* Host Port 38081 mapped to CoreOS 8081
* Host Port 38082 mapped to CoreOS 8082

Can also be configured via VirtualBox GUI, selecting `Network > Adapter 1 > Port Forwarding`

## Enterprise Version and License (.lic) file

By default Vagrant will try to run Community Containers; if you want to use Enterprise, there are 3 simple actions to take in order to use an Alfresco license:

1. Save your `.lic` file as `$PWD/license/Alfresco_Software-LC_ent42.lic`; alternatively, edit the license location in `scripts/run-docker-images.sh`

2. If you're planning to use Alfresco Enterprise versions, you need to setup your Alfresco Private Repository credentials in ```common/data_bags/maven_repos/private.json```
```
{
  "id":"private",
  "url": "https://artifacts.alfresco.com/nexus/content/groups/private",
  "username":"<your_username>",
  "password":"<your_password>"
}
```

3. Make sure that your Packer JSON file contains the following property:
```
"provisioners": [
    {
        ...
        "json": {
            ...
            "alfresco": {
                ...
                "properties": {
                    ...
                    "dir.license.external" : "/alflicense"
```

## Running CoreOS

You can use Vagrant to create/access the CoreOS server by simply running `vagrant up` from this folder; you'll be requested to provide Administration credentials, unless you edit '/etc/sudoers' as described by the [NFS Vagrant docs](https://docs.vagrantup.com/v2/synced-folders/nfs.html)

The process could take some time (15minutes, up to hours, depending on your Internet connection speed), but when you log into the CoreOS box everything is ready for use.

### Docker Images

The following Docker Images are developed using [chef-alfresco](https://github.com/maoo/chef-alfresco) and published on [Docker Registry Hub](https://hub.docker.com/u/maoo/); check `scripts/pull-docker-images.sh` for more info.

#### 3rd-party Docker Images

- orchardup/mysql:latest
- busybox:latest
- crosbymichael/skydns
- crosbymichael/skydock

#### Base Docker Images

- maoo/alfresco-base:latest
- maoo/alfresco-web-base:latest
- maoo/alfresco-repo-base:latest

#### Allinone Docker Images

- maoo/alfresco-allinone-community:latest
- maoo/alfresco-allinone-enterprise:latest

#### Architecture-specific Docker Images

- maoo/apache-lb:latest
- maoo/alfresco-base:latest
- maoo/alfresco-web-base:latest
- maoo/alfresco-repo-base:latest
- maoo/alfresco-repo:latest
- maoo/alfresco-share:latest
- maoo/alfresco-solr:latest

### Docker Architectures

You can run one of the following architectures:
- `/alfboxes/docker/scripts/run-community.sh` - Runs an alfresco-allinone-community containing all you need
- `/alfboxes/docker/scripts/run-balanced-arch.sh` - Runs a 2 nodes cluster of alfresco-allinone-enterprise; Share and Repository are load-balanced for fault-tolerance and an `lb` container balances requests
- `/alfboxes/docker/scripts/run-distributed-arch.sh` - Runs a cluster with one Repo-only (Bulk), one Share+Repo (Frontend) and one Solr+Repo (Search) container

All mentioned architectures include the following containers:
- `skydns`, `skydock` - Used for DNS service discovery
- `data` (busybox) - Data Container that holds /var/lib/tomcat7/alf_data/contentstore
- `db` (mysql) - A MySQL Server with an empty database called `alfresco` (user/pwd is alfresco/alfresco)
Check `scripts/run-*.sh` for more info.

## Known issues

Sometimes the `vagrant up` command gets interrupted with the following error message:

> The SSH connection was unexpectedly closed by the remote end. This usually indicates that SSH within the guest machine was unable to properly start up. Please boot the VM in GUI mode to check whether it is booting properly.

The problem may caused by NFS Daemon; try to restart it, then re-run Vagrant:
```
vagrant halt
sudo /sbin/nfsd restart
vagrant up
```

## Useful commands

#### Kill/Remove all stopped Docker containers
```
vagrant ssh
docker ps -a
docker kill `docker ps --no-trunc -a -q`
docker rm `docker ps --no-trunc -a -q`
```
