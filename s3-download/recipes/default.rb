require 'aws-sdk'

s3 = AWS::S3.new

bucket_name = node["s3-download"]["bucket"]
obj_name = node["s3-download"]["obj_name"]
file_path = node["s3-download"]["file_path"]

# Log output
Chef::Log.info("#{bucket_name} #{obj_name}")

# Set bucket and object name
obj = s3.buckets["#{bucket_name}"].objects["#{obj_name}"]

# Read content to variable
file_content = obj.read

# Log output (optional)
Chef::Log.info(file_content)

# Write content to file
file "#{file_path}" do
  owner 'root'
  group 'root'
  mode '0644'
  content file_content
  action :create
end
