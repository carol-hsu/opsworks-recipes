include_recipe 'kubernetes::docker-registry-auth'

bash 'copy-auth' do
    user 'root'
    cwd '/var/lib/kubelet'
    code <<-EOH
      cp ~/.docker/config ./.dockercfg
	  sed -i '1d' ./.dockercfg  
	  sed -i '1d' ./.dockercfg  
	  sed -i '$d' ./.dockercfg  
    EOH
end
