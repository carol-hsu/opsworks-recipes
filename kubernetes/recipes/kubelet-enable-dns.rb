# enable DNS setting in kubelet and restart 

template "/etc/init.d/kubernetes-node" do
    mode "0755"
    owner "root"
    source "kubernetes-node-dns.erb"
    variables({
	  :master_url => node['kubernetes']['master_url'],
      :dns_domain => node['kubernetes']['dns_domain'],
      :dns_ip => node['kubernetes']['dns_ip']
    })
    notifies :restart, 'service[restart-kubernetes-node]', :immediately	
end

service "restart-kubernetes-node" do
	service_name 'kubernetes-node'
	action :nothing
	supports :restart => true, :stop => true, :start => true 
end
