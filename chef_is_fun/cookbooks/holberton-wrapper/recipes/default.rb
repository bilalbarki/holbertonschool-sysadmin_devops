#
# Cookbook Name:: holberton-wrapper
# Recipe:: default
#
# Copyright (C) 2016 Bilal Khan
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "openssh"
include_recipe "user"
include_recipe "ntp"

#package "ntp"
#ntp['packages']
#ntp['servers'] = ["0.us.pool.ntp.org", "1.us.pool.ntp.org"]

directory '/var/run/sshd' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

begin
  r = resources(service: 'ssh')
  if 'debian' == node['platform']
    r.provider = Chef::Provider::Service::Debian
  end
end

node.default['openssh']['server']['password_authentication'] = "no"
node.default['openssh']['server']['permit_root_login'] = "no"

user_account "holberton" do
  comment "default user"
  home "/home/holberton"
  #shell "/bin/bash"
  #password "$1$LDsAeTCD$WVtEw/s207A8i1DBMyIhF0"
  ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLQos0xVHmvV+0w5WitaiRcpdFqL8orgA8bB4V8tc6clknazeeT3azKoNZedd6wZKsLiXwQTuiEz/+9xjyccycPo/g6vNj11WSsk50lXlUCA3gUg+jgUjFebQ5KNgp1k/StuGuPo1iztkq2FqAhqf2FQIi7Xvw9VQIccD3ngXf4RcKMt6OUJC0vRQb6y7NrPAWhxGppI76iQUw3ElokeT3ov5wtVOto/7qB0nGfpB6M7Mmh4eT3WVw/9wbvLRQZ1fn+IaAN9zg3AyDB5y+kRDuYxFrNVQFuQEaqCbbXhWGE3tqW7zTWlQxecq6pV8HAwOS1s+dpptz+9UspxomIzVx']
end

apt_repository 'dotdeb' do
  uri 'http://packages.dotdeb.org'
  components ['main']
end

package 'nginx'

service 'nginx' do
  action [ :enable, :start ]
  provider Chef::Provider::Service::Debian
end

package 'net-tools'
