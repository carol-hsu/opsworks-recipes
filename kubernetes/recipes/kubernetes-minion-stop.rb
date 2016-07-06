execute "stop-minion-daemons" do
    command <<-EOF
    kill -9 $(ps -A | grep kubernetes | awk '{print $1}')
    kill -9 $(ps -A | grep kube-proxy | awk '{print $1}')
    kill -9 $(ps -A | grep kubelet | awk '{print $1}')
    EOF
end

