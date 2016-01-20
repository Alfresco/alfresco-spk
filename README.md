# Vagrant SPK plugin

## What Is
Vagrant Software Provisioning Kit (SPK) plugin delivers a framework to test, develop and release immutable images and stack configurations.

You can read more about the [SPK Concept](CONCEPTS.md)

## Features
Vagrant SPK plugin provides 2 commands:
- `vagrant spk run-stack` - Given a stack template configuration, it runs a local set of Vagrant machines locally; think of it as an abstraction of [Vagrant multi-machine](https://docs.vagrantup.com/v2/multi-machine)
- `vagrant spk build-images` - Given a (optionally list of) instance image descriptors, it generates a Packer template and runs it

Check [Alfresco stack templates](https://github.com/Alfresco/alfresco-spk/tree/master/stack-templates) to get an idea of the configuration items.

Both actions use a common set of features:
- `instance-templates` - Configure Chef instance provisioning logic using [Chef JSON attribute]() file syntax; check [Alfresco instance templates](https://github.com/Alfresco/alfresco-spk/tree/master/instance-templates)
- pre and post commands - Comma-separated list of JSON files defining Shell Script items to be executed before and after the spk execution; check [Alfresco commands](https://github.com/Alfresco/alfresco-spk/tree/master/packer/commands) (mostly used for CI integration)

## Install
- Install [ChefDK](https://downloads.chef.io/chef-dk)
- Install [Vagrant](https://www.vagrantup.com/downloads.html)
- Install [Packer (0.8.6+)](https://www.packer.io/downloads.html)
- Download Vagrant SPK plugin
```
curl -L --nosession-id https://github.com/Alfresco/alfresco-spk/raw/vagrant-plugin/pkg/spk-0.1.0.gem > pkg/spk-0.1.0.gem
```
- (Or) Build Vagrant SPK plugin
```
rm Gemfile.lock ; bundle ; rake build
```
- Install Vagrant SPK plugin
```
vagrant plugin install pkg/spk-0.1.0.gem
```

## Run
The plugin comes with a comprehensive help menu:
```
╰─[:)] % vagrant spk -h
Usage: vagrant spk [build-images|run] [-b|--box-url] [-n|--box-name] [-c|--cookbooks-url] [-d|--databags-url] [-k|--ks-template] [-s|--stack-template] [-e|--pre-commands] [-o|--post-commands] [--env-vars]

    -b, --box-url [URL]              Url of the template box for the virtual machine
    -n, --box-name [NAME]            Name of the stack virtual machines
    -c, --cookbooks-url [URL]        URL resolving Berkshelf (Cookbook repo) tar.gz archive
    -d, --databags-url [URL]         URL resolving Chef databags tar.gz archive
    -k, --ks-template [PATH]         URL resolving the ks template for the machine (only used by Vagrant Box Image building)
    -s, --stack-template [PATH]      URL resolving the SPK stack template
    -e, --pre-commands [PATHS]       Comma-separated list of URLs resolving pre-commands JSON files
    -o, --post-commands [PATHS]      Comma-separated list of URLs resolving post-commands JSON files
    -v, --env-vars [PATHS]           Comma-separated list of URLs resolving environment variables JSON files
    -D, --debug                      true, to run packer in debug mode; default is false
    -w, --why-run [true|false]       Why run mode will just test configuration but will not run or build anything
```

The only mandatory parameter is `--stack-template`; all other values have [defaults](lib/spk/config.rb)
