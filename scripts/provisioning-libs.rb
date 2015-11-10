require 'json/merge_patch'
require 'json'
require 'yaml'

def getEnvParams()
  params = {}
  params['downloadCmd'] = ENV['DOWNLOAD_CMD'] || "curl --silent"
  params['workDir'] = ENV['WORK_DIR'] || "./.vagrant"
  params['packerBin'] = ENV['PACKER_BIN'] || 'packer'
  params['packerOpts'] = ENV['PACKER_OPTS'] || ''

  params['boxUrl'] = ENV['BOX_URL'] || "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.1_chef-provisionerless.box"
  params['boxName'] = ENV['BOX_NAME'] || "opscode-centos-7.1"

  params['cookbooksUrl'] = ENV['COOKBOOKS_URL'] || "https://artifacts.alfresco.com/nexus/content/repositories/snapshots/org/alfresco/devops/chef-alfresco/0.6.11/chef-alfresco-0.6.11.tar.gz"
  params['dataBagsUrl'] = ENV['DATABAGS_URL'] || ''

  params['stackTemplateUrl'] = ENV['STACK_TEMPLATE_URL'] || "file://#{ENV['PWD']}/stack-templates/community-allinone.json"

  # The following are only used by Chef remote runs
  params['chefNodeName'] = ENV['CHEF_NODE_NAME']
  params['chefInstanceTemplate'] = ENV['CHEF_INSTANCE_TEMPLATE']
  params['chefLocalYamlVarsUrl'] = ENV['CHEF_LOCAL_YAML_VARS_URL']
  params['chefLocalJsonVars'] = ENV['CHEF_LOCAL_JSON_VARS']

  print "Returning #{params.length} Environment params\n"
  return params
end

def initWorkDir(workDir)
  `mkdir -p #{workDir}/packer`
  `mkdir -p #{workDir}/alf_data`
  `chmod 777 #{workDir}/alf_data`
  print "Created #{workDir}/packer #{workDir}/alf_data folders\n"
end

def getStackTemplateNodes(downloadCmd, workDir, stackTemplateUrl)
  # Download nodes URL
  `#{downloadCmd} #{stackTemplateUrl} > #{workDir}/nodes.json`
  print "Downloaded #{stackTemplateUrl} into #{workDir}/nodes.json\n"

  print "Returning Stack template nodes parsed from #{stackTemplateUrl} into #{workDir}/nodes.json\n"
  return JSON.parse(File.read("#{workDir}/nodes.json"))
end

def yamlToJson(yaml)
  data = YAML::load(yaml)
  return JSON.dump(data)
end

def printVars(params)
  print "#START - Printing out Vagrant environment variables:\n"
  params.each do |paramName,paramValue|
    print "#{paramName}: '"+paramValue+"'\n"
  end
  print "#END - Printing out Vagrant environment variables:\n"
end

def downloadArtifact(workDir, downloadCmd, url, artifactName)
  # Download and uncompress Chef cookbooks (in a Berkshelf package format)
  if url and url.length != 0
    `#{downloadCmd} #{url} > #{workDir}/cookbooks.tar.gz`
    print "Downloaded #{url}\n"
    `rm -rf #{workDir}/#{artifactName}; tar xzf #{workDir}/#{artifactName}.tar.gz -C #{workDir}`
    print "Unpacked #{workDir}/#{artifactName}.tar.gz into #{workDir}\n"
  end
end

def downloadNodeDefinition(workDir, downloadCmd, chefNodeName, instanceTemplate, localYamlVarsUrl, localJsonVars)
  print "Processing node '#{chefNodeName}'\n"
  `#{downloadCmd} #{instanceTemplate} > #{workDir}/attributes-#{chefNodeName}.json.original`
  print "Downloaded #{instanceTemplate} into #{workDir}/attributes-#{chefNodeName}.json.original\n"

  # If a Yaml file Url is specified, override Json definition
  if localYamlVarsUrl
    `#{downloadCmd} #{localYamlVarsUrl} > #{workDir}/local-yaml-vars-#{chefNodeName}.yml`
    localJsonVars = yamlToJson(File.read("#{workDir}/local-yaml-vars-#{chefNodeName}.yml"))
    print "Downloaded #{localYamlVarsUrl} into #{workDir}/local-yaml-vars-#{chefNodeName}.yml\n"
  else
    localJsonVars = localJsonVars.to_json
  end

  # If localVars are defined, overlay the instance template JSON
  if localJsonVars
    # Debugging purposes
    # print "Printing out local JSON Variables:\n"
    # print localJsonVars + "\n"

    mergedAttributes = JSON.parse(JSON.merge(File.read("#{workDir}/attributes-#{chefNodeName}.json.original"), localJsonVars))
  end

  if ENV['NEXUS_USERNAME'] and ENV['NEXUS_PASSWORD']
    mergedAttributes['artifact-deployer'] = {}
    mergedAttributes['artifact-deployer']['maven'] = {}
    mergedAttributes['artifact-deployer']['maven']['repositories'] = {}
    mergedAttributes['artifact-deployer']['maven']['repositories']['private'] = {}

    mergedAttributes['artifact-deployer']['maven']['repositories']['private']['url'] = "https://artifacts.alfresco.com/nexus/content/groups/private"
    mergedAttributes['artifact-deployer']['maven']['repositories']['private']['username'] = ENV['NEXUS_USERNAME']
    mergedAttributes['artifact-deployer']['maven']['repositories']['private']['password'] = ENV['NEXUS_PASSWORD']
  end

  attributeFile = File.open("#{workDir}/attributes-#{chefNodeName}.json", 'w')
  attributeFile.write(mergedAttributes.to_json)
  attributeFile.close()

  print "Merged #{workDir}/attributes-#{chefNodeName}.json.original and #{workDir}/localVars.json into #{workDir}/attributes-#{chefNodeName}.json\n"
end

def mergePackerElementWithNodeAttributes(workDir, chefNodeName, provisionerName, provisioner)
  provisionerJson = JSON.parse(provisioner)
  nodeUrl = "#{workDir}/attributes-#{chefNodeName}.json"
  nodeUrlContent = File.read("#{workDir}/attributes-#{chefNodeName}.json.original")
  provisionerJson['json'] = JSON.parse(nodeUrlContent)
  provisionerFile = File.open("#{workDir}/packer/#{provisionerName}-provisioner.json", 'w')
  provisionerFile.write(provisionerJson.to_json)
  provisionerFile.close()
  provisioner = File.read("#{workDir}/packer/#{provisionerName}-provisioner.json")
end

# packerElement can be 'provisioners' or 'builders'; it's used to parse JSON input structure
# packerElementType can be 'provisioner' or 'builder'; it's used to name files
def parsePackerElements(downloadCmd, workDir, chefNode, chefNodeName, packerElementType, packerElement)
  provisionerUrls = chefNode['images'][packerElement]
  ret = "["
  urls.each do |elementName,url|
    `#{downloadCmd} #{url} > #{workDir}/packer/#{elementName}-#{packerElementType}.json`
    print "Downloaded #{provisionerUrl} into #{workDir}/packer/#{provisionerName}-#{packerElementType}.json\n"
    element = File.read("#{workDir}/packer/#{provisionerName}-#{packerElementType}.json")

    # Inject Chef attributes JSON into the chef-solo provisioner
    if elementName == 'chef-solo'
      mergePackerElementWithNodeAttributes(workDir, chefNodeName, elementName, element)
    end
    ret += element + ","
  end
  ret = ret[0..-2]
  ret += "]"
  return ret
end

def getPackerDefinitions(nodes)
  packerDefinitions = {}
  nodes.each do |chefNodeName,chefNode|
    # Compose Packer JSON
    provisioners = parsePackerElements(workDir, chefNode, chefNodeName, 'provisioner', 'provisioners')
    builders = parsePackerElements(workDir, chefNode, chefNodeName, 'builder', 'builders')
    packerDefs[chefNodeName] = "{\"builders\":#{builders},\"provisioners\":#{provisioners}}"
  end
  return packerDefinitions
end

def getNodeAttributes(workDir, chefNodeName)
  boxAttributesContent = File.read("#{workDir}/attributes-#{chefNodeName}.json")
  return JSON.parse(boxAttributesContent)
end

def runPackerDefinitions(nodes, workDir, packerBin, packerOpts)
  # Summarise Packer suites and ask for confirmation before running it
  print "Running the following Packer templates:\n"
  packerDefs.each do |packerDefName,packerDef|
    print "- #{packerDefName}-packer.json\n"
  end
  packerDefs.each do |packerDefName,packerDef|
    packerFile = File.open("#{workDir}/packer/#{packerDefName}-packer.json", 'w')
    packerFile.write(packerDef)
    packerFile.close()
    `cd #{workDir}/packer; #{packerBin} build #{packerDefName}-packer.json #{packerOpts}`
  end
end

def downloadChefItems(nodes, workDir, downloadCmd, cookbooksUrl, dataBagsUrl)
  downloadArtifact(workDir, downloadCmd, cookbooksUrl, "cookbooks")
  downloadArtifact(workDir, downloadCmd, dataBagsUrl, "databags")

  # Download node URL
  nodes.each do |chefNodeName,chefNode|
    downloadNodeDefinition(workDir, downloadCmd, chefNodeName, chefNode['instance-template']['url'], chefNode['instance-template']['overlayYamlUrl'], chefNode['instance-template']['overlay'])
  end
end

def installChef()
  `curl --silent https://www.opscode.com/chef/install.sh | bash`
end

def runChef(workDir, chefAttributePath)
    `cd #{workDir} ; chef-client -z -j #{chefAttributePath}`
end
