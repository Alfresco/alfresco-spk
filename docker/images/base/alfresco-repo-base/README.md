Alfresco Repo Base
---

This image is based on [Alfresco Web Base](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-web-base) and adds Alfresco 3rd software that is necessary to perform Alfresco transformations, specifically:
- Libreoffice
- ImageMagick
- SWF Tools

It uses [chef-alfresco](https://github.com/maoo/chef-alfresco) with the following configurations:
```
"json": {
  "alfresco": {
    "components": ["3rdparty"]
  }
}
```

The main purpose of this image is to serve Chef-based installations of Alfresco Repository (and optionally additional) application via WAR and (optionally) configurations of a shared classloader.

This image is not meant to be used with `docker run`; use [alfresco-arch](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/arch) or [alfresco-allinone](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/allinone) images instead.

Source code is hosted by [alfresco-boxes](https://github.com/maoo/alfresco-boxes/tree/master/docker/images/base/alfresco-repo-base), Docker image is hosted by [Docker public Registry](https://registry.hub.docker.com/u/maoo/alfresco-repo-base)
