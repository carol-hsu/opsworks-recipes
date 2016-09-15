chef_version = Chef::VERSION
major_version = chef_version.split(".")[0]

members = Array.new
ip_enable_ba = nil

if major_version == "11"
    node['opsworks']['layers']['etcd']['instances'].each do |inst|
	    members << inst[0]+"=http://"+inst[1][:private_ip]+":2380"
	    if ip_enable_ba == nil
		    ip_enable_ba = inst[1][:private_ip]
	    end
    end
    instance = node['opsworks']['instance']

else #Chef 12
    search(:node, "name:etcd*").each do |inst|
        members << inst['hostname']+"=http://"+inst['ipaddress']+":2380"
        if ip_enable_ba == nil
            ip_enable_ba = inst['ipaddress']
        end
    end
    instance = search("aws_opsworks_instance", "self:true").first

end

private_ip = instance['private_ip']
hostname = instance['hostname']

template "/root/etcd_static_bootstrap.sh" do
	mode "0755"
	owner "root"
	source "etcd_static_bootstrap.sh.erb"
	variables ({
		:hostname => hostname,
		:members => members.join(','),
		:private_ip => private_ip,
		:token_postfix => node[:token]
	})
	notifies :stop, "service[etcd]", :delayed
end

service 'etcd' do
	action :nothing
	notifies :run, "bash[etcd_bootstrap]", :delayed
end

bash 'etcd_bootstrap' do
	user 'root'
	cwd '/root'
	code <<-EOH
	rm -rf #{hostname}.etcd
	./etcd_static_bootstrap.sh
	EOH
	action :nothing
end

if private_ip == ip_enable_ba
	template "/root/etcd_enable_ba.sh" do
	    mode "0755"
	    owner "root"
	    source "etcd_enable_ba.sh.erb"
	    variables :etcd_password => node['etcd']['password']
	end
	
	bash 'ba_setup' do
	    user 'root'
	    cwd '/root'
	    code <<-EOH
	    tries=0
	    while [ $tries -lt 10 ]; do
	        sleep 1
	        tries=$((tries + 1))
	    done
	
	    /root/etcd_enable_ba.sh
	
	    EOH
	    action :nothing
	    subscribes :run, "bash[etcd_bootstrap]", :delayed
	end
end

