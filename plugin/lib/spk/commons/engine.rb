require 'json/merge_patch'
require 'json'
require 'yaml'

module VagrantPlugins
	module Spk
		module Commons
			class Engine

				# Populate alfresco home folder.
				def create_work_dir(work_dir)
				  `mkdir -p #{work_dir}/packer`
				  `mkdir -p #{work_dir}/alf_data`
				  `chmod 777 #{work_dir}/alf_data`
				  print "Created #{work_dir}/packer #{work_dir}/alf_data folders\n"
				end


				def get_stack_template_nodes(command, work_dir, stack_template, ks_template)
				  # Download nodes URL
				  download_file(command, stack_template, "#{work_dir}/nodes.json")
				  download_file(command, ks_template ,"#{work_dir}/ks-centos.cfg")
				  return JSON.parse(File.read("#{work_dir}/nodes.json"))
				end

				def get_chef_items(nodes, work_dir, command, cookbooks_url, databags_url)
				  get_artifact(work_dir, command, cookbooks_url, "cookbooks")
				  get_artifact(work_dir, command, databags_url, "databags")
				  prefix = "file://#{File.expand_path File.dirname(__FILE__)}/../../../files"
				  # Download node URL
				  nodes.each do |name,node|
				    get_node_definition(work_dir, command, name, "#{prefix}/#{node['instance-template']['url']}", node['instance-template']['overlayYamlUrl'], node['instance-template']['overlay'] )
				  end
				end


				def get_packer_defs(command, work_dir, nodes)
				  packer_defs = {}
				  nodes.each do |chef_node_name,chef_node|
				    # Compose Packer JSON
				    provisioners = parse_packer_elements(command, work_dir, chef_node, chef_node_name, 'provisioner', 'provisioners')
				    builders = parse_packer_elements(command, work_dir, chef_node, chef_node_name, 'builder', 'builders')
				    postprocessors = parse_packer_elements(command, work_dir, chef_node, chef_node_name, 'postprocessor', 'postprocessors')

				    # For debugging purposes
				    # print "Packer Builders: #{builders}\n"
				    # print "Packer Provisioners: #{provisioners}\n"

				    variables = chef_node['images']['variables'].to_json
				    packer_defs[chef_node_name] = "{\"variables\":#{variables},\"builders\":#{builders},\"provisioners\":#{provisioners},\"post-processors\":#{postprocessors}}"
				  end
				  return packer_defs
				end


				def run_packer_defs(packer_defs, work_dir, packer_bin, packer_opts, packer_log)
				  # Summarise Packer suites and ask for confirmation before running it
				  print "Running the following Packer templates:\n"
				  packer_defs.each do |packer_definition,packerDef|
				    print "- #{packer_definition}-packer.json\n"
				  end
				  print "Check #{packer_log} for logs.\n"

				  packer_defs.each do |packer_definition,packerDef|
				    packerFile = File.open("#{work_dir}/packer/#{packer_definition}-packer.json", 'w')
				    packerFile.write(packerDef)
				    packerFile.close()

				    print "Executing Packer template '#{packer_definition}-packer.json' (~ 60 minutes run)\n"
				    `cd #{work_dir}/packer; #{packer_bin} build #{packer_definition}-packer.json #{packer_opts} >> #{packer_log}`
				  end
				end

				def get_node_attrs(work_dir, chef_node_name)
				  box_attrs = File.read("#{work_dir}/attributes-#{chef_node_name}.json")
				  return JSON.parse(box_attrs)
				end

				private

				def download_file(command, url, destination)
				  `#{command} #{url} > #{destination}`
				  if File.zero?(destination)
				    abort("Error downloading #{url} into #{destination}! File has 0 bytes; aborting")
				  else
				    print "Downloaded #{url} into #{destination}\n"
				  end
				end

	
	      def get_node_definition(work_dir, command, node_name, instance_template, local_yaml_url, local_json_vars)
					  print "Processing node '#{node_name}'\n"
					  download_file(command, instance_template, "#{work_dir}/attributes-#{node_name}.json.original")

					  # If a Yaml file Url is specified, override Json definition
					  if local_yaml_url
					    download_file(command, local_yaml_url, "#{work_dir}/local-yaml-vars-#{node_name}.yml")
					    local_json_vars = yaml_to_json(File.read("#{work_dir}/local-yaml-vars-#{node_name}.yml"))
					  else
					    local_json_vars = local_json_vars.to_json
					  end

					  # If localVars are defined, overlay the instance template JSON
					  if local_json_vars
					    # Debugging purposes
					    # print "Printing out local JSON Variables:\n"
					    # print local_json_vars + "\n"

					    merged_attrs = JSON.parse(JSON.merge(File.read("#{work_dir}/attributes-#{node_name}.json.original"), local_json_vars))
					  end

					  merged_attrs = get_nexus_creds(merged_attrs)

					  attr_file = File.open("#{work_dir}/attributes-#{node_name}.json", 'w')
					  attr_file.write(merged_attrs.to_json)
					  attr_file.close()

					  print "Merged #{work_dir}/attributes-#{node_name}.json.original and #{work_dir}/localVars.json into #{work_dir}/attributes-#{node_name}.json\n"
				end


				def merge_elements(work_dir, chef_node_name, provisioner_name, provisioner)
				  json_provisioner = JSON.parse(provisioner)
				  node_url = "#{work_dir}/attributes-#{chef_node_name}.json"
				  node_url_content = File.read("#{work_dir}/attributes-#{chef_node_name}.json.original")
				  json_provisioner['json'] = JSON.parse(node_url_content)
				  json_provisioner['json'] = get_nexus_creds(json_provisioner['json'])
				  return json_provisioner.to_json
				end

				# packer_element can be 'provisioners' or 'builders'; it's used to parse JSON input structure
				# packer_element_type can be 'provisioner' or 'builder'; it's used to name files
				def parse_packer_elements(command, work_dir, chef_node, chef_node_name, packer_element_type, packer_element)
				  urls = chef_node['images'][packer_element]
				  ret = "["
				  prefix = "#{File.expand_path File.dirname(__FILE__)}/../../../files"
				  urls.each do |element_name,url|
				    packer_filename = "#{work_dir}/packer/#{element_name}-#{packer_element_type}.json"
				    download_file(command, "#{prefix}/#{url}", packer_filename)
				    element = File.read(packer_filename)

				    # Inject Chef attributes JSON into the chef-solo provisioner
				    if element_name == 'chef-alfresco'
				      element = merge_elements(work_dir, chef_node_name, element_name, element)
				    end
				    ret += element + ","
				  end
				  ret = ret[0..-2]
				  ret += "]"
				  return ret
				end


				def get_nexus_creds(json_attrs)
				  ret = json_attrs
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

				def get_artifact(work_dir, command, url, artifact_name)
				  # Download and uncompress Chef artifacts (in a Berkshelf package format)
				  if url and url.length != 0
				    download_file(command, url, "#{work_dir}/#{artifact_name}.tar.gz")
				    `rm -rf #{work_dir}/#{artifact_name}; tar xzf #{work_dir}/#{artifact_name}.tar.gz -C #{work_dir}`
				    print "Unpacked #{work_dir}/#{artifact_name}.tar.gz into #{work_dir}\n"
				  end
				end

				def yaml_to_json(yaml)
					 data = YAML::load(yaml)
					 return JSON.dump(data)
				end
			end
		end
	end
end