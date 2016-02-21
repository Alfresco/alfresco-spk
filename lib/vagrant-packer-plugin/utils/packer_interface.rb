require 'packer-config'
require 'json/merge_patch'
require 'vagrant-packer-plugin/patches/runner'
require 'vagrant-packer-plugin/patches/dataobject'
require 'vagrant-packer-plugin/utils/downloader'
require 'pry'

class PackerInterface
	def initialize(params, engine)
		@params = params
		@engine = engine
	end

  def get_defs(nodes)
	  packer_defs = {}
	  nodes.each do |_node_name,node|
			node_name = node['name']
	  	pconfig = Packer::Config.new "#{@params.work_dir}/#{node_name}-packer.json"
	    pconfig.description "VirtualBox vagrant for #{node_name}"

	    # => Building the packer config object variables
	    node['_images']['variables'].each {|variable_name, value| pconfig.add_variable "#{variable_name}", "#{value}"}
	    # => Building the packer config components: Builders, Provisioners and PostProcessors
	   	parametrize(pconfig, "Builder", parse_packer_elements(node, node_name, 'builder', 'builders'))
	    parametrize(pconfig, "Provisioner", parse_packer_elements(node, node_name, 'provisioner', 'provisioners'))
	    parametrize(pconfig, "PostProcessor", parse_packer_elements(node, node_name, 'postprocessor', 'postprocessors'))
	    ENV['COOKBOOK_VERSION'] = @engine.fetch_cookbook_version
	    pconfig.validate
	    packer_defs[node_name] = pconfig
	  end

	  return packer_defs
	end

	def run_defs(packer_defs)
	  # Summarise Packer suites and ask for confirmation before running it
	  print "[packer-info] Running the following Packer templates:\n"
	  packer_defs.each do |packer_definition, packer|
	    print "[packer-info] Building #{packer_definition}-packer.json\n"
	    packer.packer_options << "-debug" if @params.debug
	    packer.build
	  end
	end

	private

	# packer_element can be 'provisioners' or 'builders'; it's used to parse JSON input structure
	# packer_element_type can be 'provisioner' or 'builder'; it's used to name files
	def parse_packer_elements(node, node_name, packer_element_type, packer_element)
	  urls = node['_images'][packer_element]
	  ret = "["
		if urls
		  urls.each do |element_name,url|
		    packer_filename = "#{@params.work_dir}/#{element_name}-#{packer_element_type}.json"
		    Downloader.get(url, packer_filename)
		    element = File.read(packer_filename)
				elementJson = JSON.parse(element)

		    # Inject Chef attributes JSON into the chef-solo provisioner
		    if elementJson['type'] == 'chef-solo'
		      element = inject_chef_attributes(node['name'], element_name, elementJson)
		    end
		    ret += element + ","
		  end
		  ret = ret[0..-2]
		end
	  ret += "]"
	  return ret
	end

	def inject_chef_attributes(node_name, provisioner_name, json_provisioner)
	  node_url = "#{@params.work_dir}/attributes-#{node_name}.json"
	  node_url_content = File.read("#{@params.work_dir}/attributes-#{node_name}.json")
	  json_provisioner['json'] = JSON.parse(node_url_content)
		json_provisioner['json']['_images'] = {} if json_provisioner['json']['_images']
	  return json_provisioner.to_json
	end

	def parametrize(packer, type, components)
		JSON.parse(components).each do |component|
    	class_name = "Packer::#{type}::#{component['type'].upcase.gsub('-','_')}"
    	config = packer.send("add_#{type.downcase}", Object.const_get(class_name))

    	# Little bit difficult to understand without knowing what is the .send command in ruby
    	# Basically this iterate through the entire json object and add the variable to the packer config.
    	# Since the keys of the json object are the same name of the packer config method, i can call them iteratively
    	# For example config.send("output_file", "example.box") is equal to config.output_file "example.box"
    	component.each do |key, value|
    		config.send("#{key}", value) if key != "type"
    	end

			if type == "Provisioner" and component['type'] == "chef-solo"
    		config.required = ["type"]

				if packer.variables["run_list"]
					config.run_list packer.variables["run_list"].split(",")
				else
					config.run_list component["json"]["run_list"]
				end

				if @params.databags_url
					config.data_bags_path "#{@params.work_dir}/data_bags"
				end

				if @params.berksfile || @params.cookbooks_url
					config.cookbook_paths ["#{@params.work_dir}/cookbooks"]
				end
    	end

    	# => The current chef-solo provisioner has a bug in which will not start as it requires an empty array to start
    	# => this is a bug, and a pull request is on it's way to solve this problem

    	# => We don't specify a communicator, and packer-config require one. So if it's not required, we will use ssh
    	if type == "Builder"
    		config.communicator "ssh" if component["communicator"].nil?
    	end
    end
	end
end
