bash 'install_ds' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  
  yum -y install wget
  wget #{node['deep_security']['download_url']} -O /tmp/agent.rpm --no-check-certificate --quiet
  rpm -ihv /tmp/agent.rpm
  sleep 15
  /opt/ds_agent/dsa_control -r
  /opt/ds_agent/dsa_control -a #{node['deep_security']['dsm']} "tenantID:#{node['deep_security']['tenant_id']}" "tenantPassword:#{node['deep_security']['tenant_password']}"

  EOH
end
