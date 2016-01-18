require 'packer-config'
require 'json/merge_patch'
require 'spk/utils/downloader'

class PackerInterface
	def initialize(work_dir, engine)
		@work_dir = work_dir
		@engine = engine
	end
	
  def get_defs(nodes)
	  packer_defs = {}
	  nodes.each do |chef_node_name,chef_node|
	    # Compose Packer JSON
	    provisioners = parse_packer_elements(chef_node, chef_node_name, 'provisioner', 'provisioners')
	    builders = parse_packer_elements(chef_node, chef_node_name, 'builder', 'builders')
	    postprocessors = parse_packer_elements(chef_node, chef_node_name, 'postprocessor', 'postprocessors')

	    # For debugging purposes
	    # print "Packer Builders: #{builders}\n"
	    # print "Packer Provisioners: #{provisioners}\n"

	    variables = chef_node['images']['variables'].to_json
	    packer_defs[chef_node_name] = "{\"variables\":#{variables},\"builders\":#{builders},\"provisioners\":#{provisioners},\"post-processors\":#{postprocessors}}"
	  end
	  return packer_defs
	end

	def run_defs(packer_defs, packer_bin, packer_opts)
	  # Summarise Packer suites and ask for confirmation before running it
	  print "[spk-info] Running the following Packer templates:\n"
	  packer_defs.each do |packer_definition,packerDef|
	    print "[spk-info] #{packer_definition}-packer.json\n"
	  end
	  print "[spk-info] Check packer.log for logs.\n"

	  packer_defs.each do |packer_definition,packerDef|
	    packerFile = File.open("#{@work_dir}/packer/#{packer_definition}-packer.json", 'w')
	    packerFile.write(packerDef)
	    packerFile.close()

	    print "[spk-info] Executing Packer template '#{packer_definition}-packer.json' (~ 60 minutes run)\n"
	    `cd #{@work_dir}/packer; #{packer_bin} build #{packer_opts} #{packer_definition}-packer.json > packer.log`
	  end
	end
	private

	# packer_element can be 'provisioners' or 'builders'; it's used to parse JSON input structure
	# packer_element_type can be 'provisioner' or 'builder'; it's used to name files
	def parse_packer_elements(chef_node, chef_node_name, packer_element_type, packer_element)
	  urls = chef_node['images'][packer_element]
	  ret = "["
		if urls
		  urls.each do |element_name,url|
		    packer_filename = "#{@work_dir}/packer/#{element_name}-#{packer_element_type}.json"
		    Downloader.get(url, packer_filename)
		    element = File.read(packer_filename)

		    # Inject Chef attributes JSON into the chef-solo provisioner
		    if element_name == 'chef-alfresco'
		      element = merge_elements(@work_dir, chef_node_name, element_name, element)
		    end
		    ret += element + ","
		  end
		  ret = ret[0..-2]
		end
	  ret += "]"
	  return ret
	end


	def merge_elements(chef_node_name, provisioner_name, provisioner)
	  json_provisioner = JSON.parse(provisioner)
	  node_url = "#{@work_dir}/attributes-#{chef_node_name}.json"
	  node_url_content = File.read("#{@work_dir}/attributes-#{chef_node_name}.json.original")
	  json_provisioner['json'] = JSON.parse(node_url_content)
	  json_provisioner['json'] = @engine.get_nexus_creds(json_provisioner['json'])
	  return json_provisioner.to_json
	end

end