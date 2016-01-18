require 'spk/utils/downloader'
require 'spk/utils/unpacker'
require 'json/merge_patch'
require 'fileutils'
require 'json'
require 'yaml'
require 'open3'
require 'pry'



module VagrantPlugins
	module Spk
		module Commons
			class Engine

				# Populate alfresco home folder.
				def create_work_dir(work_dir)
					FileUtils.mkdir_p("#{work_dir}/packer")
					puts "[spk-info] Created #{work_dir}/packer folder\n"
				end


				def get_stack_template_nodes(work_dir, stack_template, ks_template)
					Downloader.get(ks_template, "#{work_dir}/ks-centos.cfg" )
				  return get_json(work_dir, "nodes.json", stack_template)
				end

				def get_json(work_dir, file_name, url)
					Downloader.get(url, "#{work_dir}/#{file_name}")
				  return JSON.parse(File.read("#{work_dir}/#{file_name}"))
				end

				def get_chef_items(nodes, work_dir, cookbooks_url, databags_url)
				  get_artifact(work_dir, cookbooks_url, "cookbooks")
				  get_artifact(work_dir, databags_url, "databags")
				  # Download node URL
				  nodes.each do |name,node|
						get_node_definition(work_dir, name, "#{node['instance-template']['url']}", node['instance-template']['overlayYamlUrl'], node['instance-template']['overlay'] )
				  end
				end


				def get_node_attrs(work_dir, chef_node_name)
				  box_attrs = File.read("#{work_dir}/attributes-#{chef_node_name}.json")
				  return JSON.parse(box_attrs)
				end

				private


	      def get_node_definition(work_dir, node_name, instance_template, local_yaml_url, local_json_vars)
					  print "Processing node '#{node_name}'\n"
					  Downloader.get(instance_template, "#{work_dir}/attributes-#{node_name}.json.original" )

					  # If a Yaml file Url is specified, override Json definition
					  if local_yaml_url
					  	Downloader.get(local_yaml_url, "#{work_dir}/local-yaml-vars-#{node_name}.yml")
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




				def get_artifact(work_dir, url, artifact_name)
				  # Download and uncompress Chef artifacts (in a Berkshelf package format)
				  if url and url.length != 0
				  	Downloader.get(url, "#{work_dir}/#{artifact_name}.tar.gz")
				  	FileUtils.rm_rf("#{work_dir}/#{artifact_name}")
				  	Unpacker.tar("#{artifact_name}.tar.gz", work_dir)
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
