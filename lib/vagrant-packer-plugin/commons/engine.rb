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

				def fetch_cookbook_version
					result = ""
					begin
						result = open("#{Dir.pwd}/metadata.rb").grep(/version/).first.split(" ").last.gsub(/\"/,'')
					rescue
					end
					result
				end


				def create_work_dir(work_dir)
 					FileUtils.mkdir_p("#{work_dir}")
 					puts "[packer-info] Created #{work_dir} folder\n"
 				end


				def get_instance_templates(work_dir, instance_templates)
					json_ret = {}
					instance_templates.each_with_index do |instance_template,index|
						node_name = JSON.parse(File.read(instance_template))['name']
						json_ret[instance_template] = get_json(work_dir, "attributes-#{node_name}.json", instance_template)
					end
				  return json_ret
				end

				def get_json(work_dir, file_name, url)
					Downloader.get(url, "#{work_dir}/#{file_name}")
				  return JSON.parse(File.read("#{work_dir}/#{file_name}"))
				end

				# Not needed anymore
				# def get_chef_items(nodes, work_dir, cookbooks_url, databags_url)
				# 	nodes.each do |filename,node|
				# 		node['_local'] = {}
				#
				# 		attr_file = File.open("#{work_dir}/attributes-#{node['name']}.json", 'w')
				# 		attr_file.write(node.to_json)
				# 		attr_file.close()
				# 	end
				# end

				def get_node_attrs(work_dir, chef_node_name)
				  box_attrs = File.read("#{work_dir}/attributes-#{chef_node_name}.json")
				  return JSON.parse(box_attrs)
				end

				def invoke_berkshelf(work_dir, path_name)
					puts "[packer-info] Trying to delete Berksfile.lock"
					begin
						File.delete("#{Dir.pwd}/Berksfile.lock")
						puts "[packer-info] local Berksfile.lock removed!"
					rescue Errno::ENOENT
						puts "[packer-info] File not found, continuing normally.."
					end

					puts "[packer-info] Packaging Chef Cookbooks repo with berks vendor..."
					Berkshelf::Cli.start(["vendor","#{work_dir}/#{path_name}"])
					# TODO - consider also params.berksfile, but not working yet
					# Berkshelf::Cli.start(["package",@params.cookbooks_url.split('/')[-1],"-b #{@params.berksfile}"])
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
