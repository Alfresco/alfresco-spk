# Vagrant SPK plugin

## What Is
Vagrant Software Provisioning Kit (SPK) plugin delivers a framework to test, develop and release immutable images and stack configurations.

## Features
Vagrant SPK plugin provides 2 commands:
- `vagrant spk run-stack` - Given a stack template configuration, it runs a local set of Vagrant machines locally; think of it as an abstraction of [Vagrant multi-machine](https://docs.vagrantup.com/v2/multi-machine)
- `vagrant spk build-images` - Given a (optionally list of) instance image descriptors, it generates a Packer template and runs it

Check [Alfresco stack templates](https://github.com/Alfresco/alfresco-spk/tree/master/stack-templates) to get an idea of the configuration items.

Both actions use a common set of features:
- `instance-templates` - Configure Chef instance provisioning logic using [Chef JSON attribute]() file syntax; check [Alfresco instance templates](https://github.com/Alfresco/alfresco-spk/tree/master/instance-templates)
- pre and post commands - Comma-separated list of JSON files defining Shell Script items to be executed before and after the spk execution; check [Alfresco commands](https://github.com/Alfresco/alfresco-spk/tree/master/packer/commands) (mostly used for CI integration)

## Run

The plugin comes with a comprehensive help menu:
```
╰─[:)] % vagrant spk -h
Usage: vagrant spk [build-images|run] [-b|--box-url] [-n|--box-name] [-c|--cookbooks-url] [-d|--databags-url] [-k|--ks-template] [-s|--stack-template]

    -b, --box-url [URL]              Url of the template box for the virtual machine
    -n, --box-name [NAME]            Name of the stack virtual machines
    -c, --cookbooks-url [URL]        Url of the chef recipes to be run on the machine
    -d, --databags-url [URL]         Url of the databags to be applied to the chef run of the machine
    -k, --ks-template [PATH]         Path of the ks template for the machine
    -s, --stack-template [PATH]      Path of the SPK stack template
    -e, --pre-commands [PATH]        Path of the pre commands JSON
    -o, --post-commands [PATH]       Path of the post commands JSON
```

The only mandatory parameter is `--stack-template`; all other values have [defaults](lib/spk/config.rb)
