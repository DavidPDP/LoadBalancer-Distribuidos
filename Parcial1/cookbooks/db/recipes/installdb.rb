package 'mysql-server'

service 'mysqld' do
  action [:enable, :start]
end

bash 'openPort' do
  code <<-EOH
     iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
     service iptables save
  EOH
end

package 'expect'

template '/tmp/configure_mysql.sh' do
  source 'configure_mysql.sh.erb'
  variables(
    password: node[:db][:password]
  )
  mode 0777
end

bash 'configure mysql' do
  cwd '/tmp'
  code <<-EOH
    ./configure_mysql.sh
  EOH
end

template '/tmp/create_schema.sql' do
  source 'create_schema.sql.erb'
  variables(
    user_db: node[:db][:user],
    ip_web1: node[:db][:ip_web1],
    ip_web2: node[:db][:ip_web2],
    password_db: node[:db][:password]
  )
  mode 0777
end

bash 'create schema' do
  cwd '/tmp'
  code <<-EOH
    cat create_schema.sql | mysql -u root -pqwerty
  EOH
end
