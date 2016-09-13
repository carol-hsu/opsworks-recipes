include_recipe 'kubernetes::kubernetes'

bash "node-file-copy" do
    user 'root'
    cwd '/tmp/kubernetes/server/kubernetes/server/bin'
    code <<-EOH
    if [[ $(ls /usr/local/bin/kubelet) ]]; then
		current_version=$(/usr/local/bin/kubelet --version | awk -F"Kubernetes v" '{ print $2 }')
		if [ "$current_version" -eq "#{node['kubernetes']['version']}" ]; then
        	exit
    	fi
	fi
    cp kubelet kube-proxy /usr/local/bin/
    EOH
end

directory '/var/lib/kubelet' do
	owner 'root'
	group 'root'
	mode '0755'
	subscribes :create, "bash[node-file-copy]", :immediately
    action :nothing
end

directory '/etc/kubernetes' do
	owner 'root'
	group 'root'
	mode '0755'
	subscribes :create, "bash[node-file-copy]", :immediately
    action :nothing
end

template "/etc/init.d/kubernetes-node" do
	mode "0755"
	owner "root"
	source "kubernetes-node.erb"
	variables :master_url => node['kubernetes']['master_url']
	subscribes :create, "bash[node-file-copy]", :immediately
	notifies :disable, 'service[kubernetes-node]', :immediately
    action :nothing
end

service "kubernetes-node" do
	action :nothing
end
