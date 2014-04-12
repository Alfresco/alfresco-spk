name             'recipe-wrapper'
maintainer       'Maurizio Pillitu'
maintainer_email ''
license          'Apache 2.0'
description      'Just a wrapper of Chef cookbooks, check Berksfile'
version          '0.1'

%w{ build-essential apt ark resolver mysql database java tomcat openssl maven xml openoffice swftools imagemagick artifact-deployer alfresco}.each do |cookbook|
  depends cookbook
end