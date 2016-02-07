require 'vagrant-packer-plugin/utils/downloader'
require 'vagrant-packer-plugin/utils/unpacker'
require 'json/merge_patch'
require 'fileutils'
require 'json'
require 'yaml'
require 'open3'
require 'pry'



module VagrantPlugins
	module PackerBuild
		module Commons
			class Engine

				def create_work_dir(work_dir)
					FileUtils.mkdir_p("#{work_dir}/packer")
					puts "[packer-info] Created #{work_dir}/packer folder\n"
				end

				def fetch_cookbook_version
					result = ""
					begin
						result = open("#{Dir.pwd}/metadata.rb").grep(/version/).first.split(" ").last.gsub(/\"/,'')
					rescue
					end
					result
				end

				def get_instance_templates(work_dir, instance_templates, ks_template)
					Downloader.get(ks_template, "#{work_dir}/ks-centos.cfg" )
					json_ret = {}
					instance_templates.each_with_index do |instance_template,index|
						json_ret[instance_template] = get_json(work_dir, "template#{index}", instance_template)
					end
				  return json_ret
				end

				def get_json(work_dir, file_name, url)
					Downloader.get(url, "#{work_dir}/#{file_name}")
				  return JSON.parse(File.read("#{work_dir}/#{file_name}"))
				end

				def get_chef_items(nodes, work_dir, cookbooks_url, databags_url)
				  get_artifact(work_dir, cookbooks_url, "cookbooks")
				  get_artifact(work_dir, databags_url, "databags")

					nodes.each do |filename,node|
						node['_local'] = {}
						node = get_nexus_creds(node)

						attr_file = File.open("#{work_dir}/attributes-#{node['name']}.json", 'w')
						attr_file.write(node.to_json)
						attr_file.close()
					end
				end

				def get_node_attrs(work_dir, chef_node_name)
				  box_attrs = File.read("#{work_dir}/attributes-#{chef_node_name}.json")
				  return JSON.parse(box_attrs)
				end

				#TODO - this should not be here, but cannot handled within
				# provisioner, since no Packer variables are supported
				def get_nexus_creds(json_attrs)
					name = ENV['MVN_CHEF_REPO_NAME']
					url = ENV['MVN_CHEF_REPO_URL']
					username = ENV['MVN_CHEF_REPO_USERNAME']
					password = ENV['MVN_CHEF_REPO_PASSWORD']
					ret = json_attrs
				  if name and url and username and password
				    ret['artifact-deployer'] = {}
				    ret['artifact-deployer']['maven'] = {}
				    ret['artifact-deployer']['maven']['repositories'] = {}
				    ret['artifact-deployer']['maven']['repositories'][name] = {}
				    ret['artifact-deployer']['maven']['repositories'][name]['url'] = url
				    ret['artifact-deployer']['maven']['repositories'][name]['username'] = username
				    ret['artifact-deployer']['maven']['repositories'][name]['password'] = password
				  end
				  return ret
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
