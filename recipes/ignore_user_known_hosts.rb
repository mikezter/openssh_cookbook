include_recipe 'openssh::default'

execute 'known_hosts is global' do
  command %Q{echo 'GlobalKnownHostsFile /etc/ssh/ssh_known_hosts' >> /etc/ssh/ssh_config }
  not_if %Q{cat /etc/ssh/ssh_config | grep '^GlobalKnownHostsFile /etc/ssh/ssh_known_hosts$'}
end

execute 'IgnoreUserKnownHosts option is not present' do
  command %Q{sed -i -e '/^IgnoreUserKnownHosts yes$/d' /etc/ssh/sshd_config }
  only_if %Q{cat /etc/ssh/sshd_config | grep '^IgnoreUserKnownHosts yes$'}
end

file '/etc/ssh/ssh_known_hosts'