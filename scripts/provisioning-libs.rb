require 'json/merge_patch'
require 'json'
require 'yaml'

def downloadFile(downloadCmd, url, destination)
  `#{downloadCmd} #{url} > #{destination}`
  if File.zero?(destination)
    abort("Error downloading #{url} into #{destination}! File has 0 bytes; aborting")
  else
    print "Downloaded #{url} into #{destination}\n"
  end
end

def getEnvParams()
  params = {}
  params['downloadCmd'] = ENV['DOWNLOAD_CMD'] || "curl --silent"
  params['workDir'] = ENV['WORK_DIR'] || "./.vagrant"
  params['packerBin'] = ENV['PACKER_BIN'] || 'packer'
  params['packerOpts'] = ENV['PACKER_OPTS'] || ''

  params['boxUrl'] = ENV['BOX_URL'] || "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.1_chef-provisionerless.box"
  params['boxName'] = ENV['BOX_NAME'] || "opscode-centos-7.1"

  params['cookbooksUrl'] = ENV['COOKBOOKS_URL'] || "https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.13/chef-alfresco-0.6.13.tar.gz"
  params['dataBagsUrl'] = ENV['DATABAGS_URL'] || ''

  params['stackTemplateUrl'] = ENV['STACK_TEMPLATE_URL'] || "file://#{ENV['PWD']}/stack-templates/community-allinone.json"

  # The following are only used by Chef remote runs
  params['chefNodeName'] = ENV['CHEF_NODE_NAME']
  params['chefInstanceTemplate'] = ENV['CHEF_INSTANCE_TEMPLATE']
  params['chefLocalYamlVarsUrl'] = ENV['CHEF_LOCAL_YAML_VARS_URL']
  params['chefLocalJsonVars'] = ENV['CHEF_LOCAL_JSON_VARS']

  params['chefLogLevel'] = ENV['CHEF_LOG_LEVEL'] || "info"
  params['chefLogFile'] = ENV['CHEF_LOG_FILE'] || "/var/log/chef-client.log"

  # For debugging purposes
  # print "Returning #{params.length} Environment params\n"
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
  downloadFile(downloadCmd, stackTemplateUrl, "#{workDir}/nodes.json")
  return JSON.parse(File.read("#{workDir}/nodes.json"))
end

def yamlToJson(yaml)
  data = YAML::load(yaml)
  return JSON.dump(data)
end

# Used for debugging purposes
def printVars(params)
  print "#START - Printing out Vagrant environment variables:\n"
  params.each do |paramName,paramValue|
    print "#{paramName}: '"+paramValue+"'\n"
  end
  print "#END - Printing out Vagrant environment variables:\n"
end

def downloadArtifact(workDir, downloadCmd, url, artifactName)
  # Download and uncompress Chef artifacts (in a Berkshelf package format)
  if url and url.length != 0
    downloadFile(downloadCmd, url, "#{workDir}/#{artifactName}.tar.gz")
    `rm -rf #{workDir}/#{artifactName}; tar xzf #{workDir}/#{artifactName}.tar.gz -C #{workDir}`
    print "Unpacked #{workDir}/#{artifactName}.tar.gz into #{workDir}\n"
  end
end

def addNexusCredentials(attributesJson)
  ret = attributesJson
  if ENV['NEXUS_USERNAME'] and ENV['NEXUS_PASSWORD']
    ret['artifact-deployer'] = {}
    ret['artifact-deployer']['maven'] = {}
    ret['artifact-deployer']['maven']['repositories'] = {}
    ret['artifact-deployer']['maven']['repositories']['private'] = {}
    ret['artifact-deployer']['maven']['repositories']['private']['url'] = "https://artifacts.alfresco.com/nexus/content/groups/private"
    ret['artifact-deployer']['maven']['repositories']['private']['username'] = ENV['NEXUS_USERNAME']
    ret['artifact-deployer']['maven']['repositories']['private']['password'] = ENV['NEXUS_PASSWORD']
  end
  return ret
end

def downloadNodeDefinition(workDir, downloadCmd, chefNodeName, instanceTemplate, localYamlVarsUrl, localJsonVars)
  print "Processing node '#{chefNodeName}'\n"
  downloadFile(downloadCmd, instanceTemplate, "#{workDir}/attributes-#{chefNodeName}.json.original")

  # If a Yaml file Url is specified, override Json definition
  if localYamlVarsUrl
    downloadFile(downloadCmd, localYamlVarsUrl, "#{workDir}/local-yaml-vars-#{chefNodeName}.yml")
    localJsonVars = yamlToJson(File.read("#{workDir}/local-yaml-vars-#{chefNodeName}.yml"))
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

  mergedAttributes = addNexusCredentials(mergedAttributes)

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
  provisionerJson['json'] = addNexusCredentials(provisionerJson['json'])
  return provisionerJson.to_json
end

# packerElement can be 'provisioners' or 'builders'; it's used to parse JSON input structure
# packerElementType can be 'provisioner' or 'builder'; it's used to name files
def parsePackerElements(downloadCmd, workDir, chefNode, chefNodeName, packerElementType, packerElement)
  urls = chefNode['images'][packerElement]
  ret = "["
  urls.each do |elementName,url|
    packerFileName = "#{workDir}/packer/#{elementName}-#{packerElementType}.json"
    downloadFile(downloadCmd, url, packerFileName)
    element = File.read(packerFileName)

    # Inject Chef attributes JSON into the chef-solo provisioner
    if elementName == 'chef-alfresco'
      element = mergePackerElementWithNodeAttributes(workDir, chefNodeName, elementName, element)
    end
    ret += element + ","
  end
  ret = ret[0..-2]
  ret += "]"
  return ret
end

def getPackerDefinitions(downloadCmd, workDir, nodes)
  packerDefinitions = {}
  nodes.each do |chefNodeName,chefNode|
    # Compose Packer JSON
    provisioners = parsePackerElements(downloadCmd, workDir, chefNode, chefNodeName, 'provisioner', 'provisioners')
    builders = parsePackerElements(downloadCmd, workDir, chefNode, chefNodeName, 'builder', 'builders')

    # For debugging purposes
    # print "Packer Builders: #{builders}\n"
    # print "Packer Provisioners: #{provisioners}\n"

    variables = chefNode['images']['variables'].to_json
    packerDefinitions[chefNodeName] = "{\"variables\":#{variables},\"builders\":#{builders},\"provisioners\":#{provisioners}}"
  end
  return packerDefinitions
end

def getNodeAttributes(workDir, chefNodeName)
  boxAttributesContent = File.read("#{workDir}/attributes-#{chefNodeName}.json")
  return JSON.parse(boxAttributesContent)
end

def runPackerDefinitions(packerDefs, workDir, packerBin, packerOpts, packerLogFile)
  # Summarise Packer suites and ask for confirmation before running it
  print "Running the following Packer templates:\n"
  packerDefs.each do |packerDefName,packerDef|
    print "- #{packerDefName}-packer.json\n"
  end
  print "Check #{packerLogFile} for logs.\n"

  packerDefs.each do |packerDefName,packerDef|
    packerFile = File.open("#{workDir}/packer/#{packerDefName}-packer.json", 'w')
    packerFile.write(packerDef)
    packerFile.close()

    print "Executing Packer template '#{packerDefName}-packer.json' (~ 60 minutes run)\n"
    `cd #{workDir}/packer; #{packerBin} build #{packerDefName}-packer.json #{packerOpts} >> #{packerLogFile}`
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

def runChef(workDir, chefLogLevel, chefLogFile, chefAttributePath)
    `cd #{workDir} ; chef-client --log_level #{chefLogLevel} --logfile #{chefLogFile} -z -j #{chefAttributePath}`
end
