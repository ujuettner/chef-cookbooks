# Hmm, will the instance's machine type always match the tarball's filename?
mongodb_package_basename = "mongodb-linux-#{node[:kernel][:machine]}-#{node[:mongodb][:version]}"
Chef::Log.debug("mongodb_package_basename: #{mongodb_package_basename}")

remote_file "/tmp/#{mongodb_package_basename}.tgz" do
  source "http://fastdl.mongodb.org/linux/#{mongodb_package_basename}.tgz"
end

execute "tar xvfz /tmp/#{mongodb_package_basename}.tgz" do
  cwd "/tmp"
end

# TODO: Check, whether enclosed_node is really needed.
enclosed_node = node
ruby_block "Install binaries." do
  block do
    Dir.glob("/tmp/#{mongodb_package_basename}/bin/*").each do |binary|
      if not File.directory?(binary) and File.executable?(binary)
        FileUtils.install binary, "#{enclosed_node[:mongodb][:prefix]}/bin", :mode => 0755
        FileUtils.chown "root", "root", "#{enclosed_node[:mongodb][:prefix]}/bin/#{File.basename(binary)}"
      end
    end
  end
end

group node[:mongodb][:group] do
  action :create
end

user node[:mongodb][:user] do
  gid node[:mongodb][:group]
  shell "/bin/false"
  action :create
end

directory node[:mongodb][:dbpath] do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
end

directory node[:mongodb][:logpath] do
  action :create
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
end

template "/etc/init.d/mongodb" do
  source "mongodb.init.erb"
  owner "root"
  group "root"
  mode "0755"
end

service "mongodb" do
  service_name "mongodb"
  supports :status => true, :restart => true, :reload => false, "force-reload" => true, "force-stop" => true
  action :enable
end

template "/etc/mongodb.conf" do
  source "mongodb.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mongodb"), :immediately
end

