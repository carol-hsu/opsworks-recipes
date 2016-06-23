include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  
  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end

  # clean up
  bash "docker-proxy-cleanup" do
    user "root"
    code <<-EOH
      if docker ps | grep #{deploy[:application]}-proxy;
      then
        docker stop #{deploy[:application]}-proxy
        sleep 3
        docker rm #{deploy[:application]}-proxy
        sleep 3
      fi
      if docker ps -a | grep #{deploy[:application]}-proxy;
      then
        docker rm #{deploy[:application]}-proxy
        sleep 3
      fi
    EOH
  end
  
  # create cert dir
  directory "/root/.certs" do
    mode 0755
    owner 'root'
    group 'root'
    action :create
  end

  # cert
  file "/root/.certs/docker-registry.crt" do
    owner deploy[:user]
    mode 0600
    content deploy[:ssl_certificate]
    only_if do
      deploy[:ssl_support]
    end
  end

  file "/root/.certs/docker-registry.key" do
    owner deploy[:user]
    mode 0600
    content deploy[:ssl_certificate_key]
    only_if do
      deploy[:ssl_support]
    end
  end
	
  # deploy proxy
  bash "docker-proxy-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      docker run -d -p 443:443 -e REGISTRY_HOST=#{deploy[:application]} -e REGISTRY_PORT=#{deploy[:environment_variables][:service_port]} -e SERVER_NAME=localhost --link #{deploy[:application]}:#{deploy[:application]} -v /root/docker-registry.htpasswd:/etc/nginx/.htpasswd:ro -v /root/.certs:/etc/nginx/ssl:ro --name #{deploy[:application]}-proxy containersol/docker-registry-proxy 
    EOH
  end

end
