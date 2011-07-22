include_recipe 'openssh::default'

execute 'Disable PasswordAuthentication' do
  command %Q{sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config }
  only_if %Q{cat /etc/ssh/sshd_config | grep '^#PasswordAuthentication ..'}
  notifies :reload, resources(:service => 'ssh'), :delayed
end