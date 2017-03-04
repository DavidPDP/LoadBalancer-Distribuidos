package 'httpd'
package 'php'
package 'php-mysql'
package 'mysql'

service 'httpd' do
  action [:enable, :start]
end

bash 'open port' do
  code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
  service iptables save
  EOH
end

template '/var/www/html/index.php' do
  source 'index.html.erb'
  variables(
    titulo_ppal: node[:web][:titulo]
  ) 
end

template '/var/www/html/select.php' do
  source 'select.php.erb'
  variables(
    user_web: node[:web][:user],
    ip_web: node[:web][:ip],
    password_web: node[:web][:password] 
  )
end

cookbook_file '/var/www/html/.htaccess' do
  source '.htaccess'
  mode 0666
end 

cookbook_file '/var/www/html/findIP.php' do
  source 'findIP.php'
  mode 0666
end
