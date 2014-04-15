template "httpd-proxy-balancer.conf" do
  path        "#{node['lb'][':apache_conf_folder']}/httpd-proxy-balancer.conf"
  source      "httpd-proxy-balancer.conf.erb"
  owner       "root"
  group       "root"
  mode        "0660"
end

service "#{node['lb']['service_name']}" do
	action [:enable, :restart]
end