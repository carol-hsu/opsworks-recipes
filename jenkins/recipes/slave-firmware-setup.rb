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

bash 'install-required-package' do
	user 'root'
	code <<-EOH
	apt-get -y update
	apt-get -y install libasound2-dev
	apt-get -y python python-pip
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
