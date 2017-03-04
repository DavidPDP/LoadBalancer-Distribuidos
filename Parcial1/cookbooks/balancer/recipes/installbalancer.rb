bash 'open port' do
  code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
  service iptables save
  EOH
end

cookbook_file '/etc/yum.repos.d/nginx.repo' do
  source 'nginx.repo'
end 

package 'nginx'

file '/etc/nginx/nginx.conf' do
  action :delete
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  variables(
    server_ip1: node[:balancer][:server_ip1],
    server_ip2: node[:balancer][:server_ip2],
    balancer_port: node[:balancer][:balancer_port]
  )
end

service 'nginx' do
  action [:enable, :start]
end
