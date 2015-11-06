# chef-bootstrap.rb
#
# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative 'provisioning-libs'

params = getEnvParams()

workDir = ENV['WORK_DIR'] || "/tmp/chef-bootstrap"]
downloadCmd = params['downloadCmd']
cookbooksUrl = params['cookbooksUrl']
dataBagsUrl = params['dataBagsUrl']

chefNodeName = params['chefNodeName']
instanceTemplate = params['chefInstanceTemplate']
localYamlVarsUrl = params['chefLocalYamlVarsUrl']
localJsonVars = params['chefLocalJsonVars']

downloadArtifact(workDir, downloadCmd, cookbooksUrl, "cookbooks")
downloadArtifact(workDir, downloadCmd, dataBagsUrl, "databags")

downloadNodeDefinition(workDir, downloadCmd, chefNodeName, instanceTemplate, localYamlVarsUrl, localJsonVars)

runChef("#{workDir}/attributes-#{chefNodeName}.json")
