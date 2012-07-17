remote_file "/tmp/10gen-mms-agent.tar.gz" do
  source "https://mms.10gen.com/settings/10gen-mms-agent.tar.gz"
end

execute "tar xvfz /tmp/10gen-mms-agent.tar.gz" do
  cwd "/tmp"
end

group node[:mmsagent][:group] do
  action :create
end

user node[:mmsagent][:user] do
  gid node[:mmsagent][:group]
  shell "/bin/false"
  action :create
end

directory node[:mmsagent][:installdir] do
  owner node[:mmsagent][:user]
  group node[:mmsagent][:group]
  mode "0755"
end

execute "sed -i -e 's/@API_KEY@/#{node[:mmsagent][:apikey]}/g' -e 's/@SECRET_KEY@/#{node[:mmsagent][:secretkey]}/g' mms-agent/settings.py" do
  cwd "/tmp"
end

ruby_block "Install files." do
  block do
    Dir.glob(["/tmp/mms-agent/*.py", "/tmp/mms-agent/README"]).each do |file|
      if not File.directory?(file)
        FileUtils.install file, "#{node[:mmsagent][:installdir]}", :mode => 0644
        FileUtils.chown "root", "root", "#{node[:mmsagent][:installdir]}/#{File.basename(file)}"
      end
    end
  end
end

directory node[:mmsagent][:logpath] do
  action :create
  owner node[:mmsagent][:user]
  group node[:mmsagent][:group]
  mode "0755"
end

template "/etc/init.d/mmsagent" do
  source "mmsagent.init.erb"
  owner "root"
  group "root"
  mode "0755"
end

service "mmsagent" do
  service_name "mmsagent"
  supports :status => true, :restart => true, :reload => false, "force-reload" => true, "force-stop" => true
  action :enable
end

