execute 'generate-auth' do
    user 'root'
	command "docker login -u #{node['docker']['user']} -p #{node['docker']['password']} -e yoyo@trend.com #{node['docker']['registry']}"

end
