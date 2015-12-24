template "/etc/init.d/kubernetes-minion" do
	mode "0755"
	owner "root"
	source "kubernetes-minion.erb"
	variables :master_url => my_master_elb[:dns_name]
	notifies :disable, 'service[kubernetes-minion]', :delayed
end

service "kubernetes-minion" do
	action :nothing
end
