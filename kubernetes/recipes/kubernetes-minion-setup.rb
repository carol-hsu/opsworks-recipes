include_recipe 'kubernetes::kubernetes'

bash "minion-file-copy" do
    user 'root'
    cwd '/tmp//kubernetes/server/kubernetes/server/bin'
    code <<-EOH
    mkdir /var/lib/kubelet
    mkdir /etc/kubernetes
    cp kubelet kube-proxy /usr/local/bin/
    EOH
end

template "/etc/init.d/kubernetes-minion" do
	mode "0755"
	owner "root"
	source "kubernetes-minion.erb"
	variables :master_url => node['kubernetes']['master_url']
	subscribes :create, "bash[minion-file-copy]", :immediately
	notifies :disable, 'service[kubernetes-minion]', :delayed
    action :nothing
end

service "kubernetes-minion" do
	action :nothing
end
