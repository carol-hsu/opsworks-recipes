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
    fi 
  fi

  wget --max-redirect 255 https://github.com/coreos/etcd/releases/download/v#{node['etcd']['version']}/etcd-v#{node['etcd']['version']}-linux-amd64.tar.gz
  tar zxvf etcd-v#{node['etcd']['version']}-linux-amd64.tar.gz
  cd etcd-v#{node['etcd']['version']}-linux-amd64
  cp etcd etcdctl /usr/local/bin

  EOH
end

template "/etc/init.d/etcd" do
  mode "0755"
  owner "root"
  source "etcd-discovery.erb"
end

service "etcd" do
  action [:enable, :start]
  subscribes :reload, "template[/etc/init.d/etcd]", :immediately
end

