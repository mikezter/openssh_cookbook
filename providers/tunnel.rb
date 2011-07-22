def start_cmd
  "/root/autossh start #{identifier} #{new_resource.user} #{new_resource.host} #{new_resource.forwarding} #{new_resource.key} #{new_resource.port}"
end

def stop_cmd
  "/root/autossh stop #{identifier}"
end

def monit_config
  "/etc/monit/conf.d/zzz-autossh#{identifier}.conf"
end

def pidfile
  "/var/run/autossh-#{identifier}.pid"
end

def identifier
  new_resource.forwarding.gsub(/\W/, '')
end

action :create do
  cookbook_file '/root/autossh' do
    mode 0770
    source 'autossh'
    cookbook 'openssh'
  end

  execute "scan for hostkey of #{new_resource.host}" do
    known_hosts_file = '/etc/ssh/ssh_known_hosts'
    command "ssh-keyscan -p #{new_resource.port} #{new_resource.host} >> #{known_hosts_file}"
    not_if "cat #{known_hosts_file} | grep #{new_resource.host}"
  end

  execute "establish tunnel #{new_resource.name}" do
    not_if "test -f #{pidfile}"
    command start_cmd
  end

  template monit_config do
    action :create
    source 'autossh-monit.conf.erb'
    notifies_delayed :restart, resources(:service => "monit")
    variables(
     :start_cmd => start_cmd,
     :stop_cmd => stop_cmd,
     :name => new_resource.name.gsub(/\W/, ''),
     :pidfile => pidfile
    )
    cookbook 'openssh'
  end

end

action :destroy do
  execute "stop tunnel #{new_resource.name}" do
    only_if "/usr/bin/pgrep -f #{identifier}"
    command stop_cmd
  end

  file monit_config do
    action :delete
    notifies_delayed :restart, resources(:service => "monit")
  end

  # TODO: delete the host from known_hosts
end
