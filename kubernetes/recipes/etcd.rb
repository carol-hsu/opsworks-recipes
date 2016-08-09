bash 'install_etcd' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  if [ -f /usr/local/bin/etcd ]; then
    current_version=$(/usr/local/bin/etcd --version | awk 'NR==1' | awk -F":" '{ print $2 }')
    if [ "$current_version" == "#{node['etcd']['version']}" ]; then
        exit
    else
        rm -rf etcd-*-linux-amd64*
        rm -f /usr/local/bin/etcd*
    fi 
  fi

  wget --max-redirect 255 https://github.com/coreos/etcd/releases/download/v#{node['etcd']['version']}/etcd-v#{node['etcd']['version']}-linux-amd64.tar.gz
  tar zxvf etcd-v#{node['etcd']['version']}-linux-amd64.tar.gz
  cd etcd-v#{node['etcd']['version']}-linux-amd64
  cp etcd etcdctl /usr/local/bin

  EOH
end

instance = search("aws_opsworks_instance", "self:true").first

template "/etc/init.d/etcd" do
	mode "0755"
	owner "root"
	source "etcd.erb"
    variables :private_ip => instance['private_ip']  
end

service "etcd" do
	action [:enable, :start]
	subscribes :reload, "template[/etc/init.d/etcd]", :immediately
	subscribes :reload, "template[/root/etcd_enable_ba.sh]", :immediately	
end

