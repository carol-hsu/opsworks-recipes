execute "stop-master-daemons" do
    command <<-EOF
    kill -9 $(ps -A | grep kubernetes | awk '{print $1}')
    kill -9 $(ps -A | grep kube-apise | awk '{print $1}')
    kill -9 $(ps -A | grep kube-contr | awk '{print $1}')
    kill -9 $(ps -A | grep kube-sched | awk '{print $1}')
    EOF
end

