include_recipe 'kubernetes::docker-registry-auth'

bash 'copy-auth' do
    user 'root'
    cwd '/var/lib/kubelet'
    code <<-EOH
      cp ~/.docker/config ./.dockercfg
	  
    EOH
end
