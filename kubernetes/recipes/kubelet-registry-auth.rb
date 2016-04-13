include_recipe 'kubernetes::docker-registry-auth'

bash 'copy-auth' do
    user 'root'
    cwd '/var/lib/kubelet'
    code <<-EOH
      cp ~/.docker/config.json ./.dockercfg
	  sed -i '1d' ./.dockercfg  
	  sed -i '1d' ./.dockercfg  
	  sed -i '$d' ./.dockercfg  
	  sed -i '$d' ./.dockercfg  
    EOH
	notifies :restart, 'service[kubernetes-minion]', :immediately
end

service "kubernetes-minion" do
	action :nothing
	supports :restart => true, :stop => true, :start => true 
end
