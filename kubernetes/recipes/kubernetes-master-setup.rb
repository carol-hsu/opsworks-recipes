include_recipe 'kubernetes::kubernetes'

bash "master-file-copy" do
    user 'root'
    cwd '/tmp//kubernetes/server/kubernetes/server/bin'
    code <<-EOH
    mkdir /etc/kubernetes
    cp kubectl kube-apiserver kube-scheduler kube-controller-manager /usr/local/bin/
    EOH
end

etcd_endpoint="http://root:#{node['etcd']['password']}@#{node['etcd']['elb_url']}:80"

template "/etc/init.d/kubernetes-master" do
	mode "0755"
	owner "root"
	source "kubernetes-master.erb"
	variables({
	  :etcd_server => etcd_endpoint,
	  :cluster_cidr => node['kubernetes']['cluster_cidr'],
	  :ba_path => "/root/ba_file"
	})
	subscribes :create, "bash[master-file-copy]", :immediately
    action :nothing
end

file "/root/ba_file" do
	owner 'root'
	group 'root'
	mode '0600'
	content "#{node['ba']['password']},#{node['ba']['account']},#{node['ba']['uid']}"
	action :create
end


