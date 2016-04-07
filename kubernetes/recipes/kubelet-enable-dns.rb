# enable DNS setting in kubelet and restart 
include_recipe 'kubernetes::kubernetes-minion-run'

bash 'add-dns-settings' do
	code <<-EOH
		sed -i '41a \                --cluster-domain=#{node['kubernetes']['dns_domain']} \\' /etc/init.d/kubernetes-minion
		sed -i '41a \                --cluster-dns=#{node['kubernetes']['dns_ip']} \\' /etc/init.d/kubernetes-minion
		EOH
    notifies :restart, 'service[restart-kubernetes-minion]', :delayed
end

service "restart-kubernetes-minion" do
	service_name 'kubernetes-minion'
	action :nothing
	supports :restart => true, :stop => true, :start => true 
end
