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
    # install Java 1.8
	apt-add-repository -y ppa:webupd8team/java
	apt-get -y update
	echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections	
	apt-get -y install oracle-java8-installer	
    apt-get -y install ant
    EOH
end

bash 'install-required-package' do
	user 'root'
	code <<-EOH
	apt-get -y install libasound2-dev
	apt-get -y install python python-pip
	pip install awscli
	dpkg --add-architecture i386
	apt-get -y install libc6
	EOH
end

region = node["opsworks"]["instance"]["region"]
bucket = node["package_info"]["bucket_name"]

bash 'install-toolchain' do
	user 'root'
	code <<-EOH
	aws s3 --region #{region} cp s3://#{bucket}/#{node["package_info"]["package_for_version1"]} ./
	aws s3 --region #{region} cp s3://#{bucket}/#{node["package_info"]["package_for_version2"]} ./
	aws s3 --region #{region} cp s3://#{bucket}/#{node["package_info"]["package_from_kernel_for_version1"]} ./

	tar xvf #{node["package_info"]["package_for_version1"]} -C /opt
	tar xvf #{node["package_info"]["package_for_version2"]} -C /opt
	tar xvf #{node["package_info"]["package_from_kernel_for_version1"]} -C /opt

	EOH
end

Chef::Log.info("***************** Jenkins firmware slave setup finished **************")
