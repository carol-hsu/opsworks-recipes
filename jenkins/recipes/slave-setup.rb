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

bash 'install-ant' do
	user 'root'
	code <<-EOH
	yum -y update
        # yum -y install java
	yum -y install ant
        # install Java 1.8
        cd /opt/
        wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz"
        tar xzf jdk-8u121-linux-x64.tar.gz
        alternatives --install /usr/bin/java java /opt/jdk1.8.0_121/bin/java 1
        alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_121/bin/javac 1
        alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_121/bin/jar 1
        alternatives --set jar /opt/jdk1.8.0_121/bin/jar
        alternatives --set javac /opt/jdk1.8.0_121/bin/javac
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
