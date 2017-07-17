user 'jenkins' do
    home '/home/jenkins'
    shell '/bin/bash'
    action :create
end

directory '/home/jenkins' do
    owner 'jenkins'
    group 'jenkins'
end

directory '/home/jenkins/.ssh' do
	owner 'jenkins'
	group 'jenkins'
	mode '0700'
end

bash 'install-ant-and-java' do
	user 'root'
	code <<-EOH
	yum -y update
	yum -y install ant
	yum install java-1.8.0
	yum remove java-1.7.0-openjdk
    EOH
end

#install docker
bash 'install-docker' do
	user 'root'
	code <<-EOH
	yum -y install docker
	service docker start
	usermod -aG docker jenkins
	service docker restart
	EOH
end

#put cron job
template "/etc/cron.daily/docker-clean.sh" do
      mode "0755"
      owner "root"
      source "docker-clean.sh.erb"
end

Chef::Log.info("***************** Jenkins slave setup finished **************")
