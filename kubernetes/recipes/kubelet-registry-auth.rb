include_recipe 'kubernetes::docker-registry-auth'

execute 'copy-auth' do
    user 'root'
    cwd '/var/lib/kubelet'
    command 'cp ~/.dockercfg ./'
	notifies :restart, 'service[kubernetes-node]', :immediately
end

service "kubernetes-node" do
	action :nothing
	supports :restart => true, :stop => true, :start => true 
end
