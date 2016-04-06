# enable DNS setting in kubelet and restart 
include_recipe 'kubernetes::kubernetes-minion-run'

execute 'add-dns-settings' do
	command <<-EOH
    sed -i '41c \        \--cluster-domain=#{node['kubernetes']['dns_domain']}' /etc/init.d/kubernetes-minion
    sed -i '41c \        \--cluster-dns=#{node['kubernetes']['dns_ip']}' /etc/init.d/kubernetes-minion
	EOH
	not_if do "fgrep 'cluster-dns' /etc/init.d/kubernetes-minion" end
    notifies :restart, 'service[kubernetes-minion]', :delayed
end

service "kubernetes-minion" do
	action :nothing
	supports { :restart => true }
end
