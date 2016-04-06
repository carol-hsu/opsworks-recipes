# run the pod and servie of monitoring system
include_recipe 'kubernetes::kubernetes-master-run'
unless Dir.exist?('/opt/monitoring-template') #should access etcd for sure
	directory "/opt/monitoring-template" do
		 owner 'root'
    	 group 'root'
    	 mode '0755'
    	 action :create
    	 notifies :create, 'template[/opt/monitoring-template/grafana-service.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/heapster-service.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/influxdb-service.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/heapster-controller.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/influxdb-grafana-controller.yaml]', :immediately
	end
end

template "/opt/dns-template/skydns-rc.yaml" do
    mode "0644"
    owner "root"
    source "skydns-rc.yaml.erb"
    variables :dns_domain => node['kubernetes']['dns_domain']
    notifies :run, "execute[wait_apiserver_running]", :delayed
    action :nothing
end

template "/opt/dns-template/skydns-svc.yaml" do
    mode "0644"
    owner "root"
    source "skydns-svc.yaml.erb"
    variables :dns_ip => node['kubernetes']['dns_ip']
    notifies :run, "execute[wait_apiserver_running]", :delayed
    action :nothing
end

execute 'wait_apiserver_running' do
	command "sleep 10"
    action :nothing
    notifies :run, 'execute[run-rc]', :delayed
    notifies :run, 'execute[run-svc]', :delayed
end


execute "run-rc" do
    cwd "/opt/dns-template/"
    command "kubectl create -f skydns-rc.yaml"
    action :nothing
end

execute "run-svc" do
    cwd "/opt/dns-template/"
    command "kubectl create -f skydns-svc.yaml"
    action :nothing
end

