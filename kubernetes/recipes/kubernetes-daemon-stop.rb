execute "stop-kubernetes-daemons" do
    command "kill -9 $(ps -A | grep kubernetes | awk '{print $1}')"	
end
