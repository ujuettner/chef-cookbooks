# Hmm, will the instance's machine type always match the tarball's filename?
mongodb_package_basename = "mongodb-linux-#{node[:kernel][:machine]}-#{node[:mongodb][:version]}"
Chef::Log.info("mongodb_package_basename: #{mongodb_package_basename}")

remote_file "/tmp/#{mongodb_package_basename}.tgz" do
  source "http://fastdl.mongodb.org/linux/#{mongodb_package_basename}.tgz"
end

execute "tar xvfz /tmp/#{mongodb_package_basename}.tgz" do
  cwd "/tmp"
end

enclosed_node = node
ruby_block "Install binaries" do
  block do
    # TODO: Get the list of binaries dynamically instead of using a static array.
    %w{bsondump mongo mongod mongodump mongoexport mongofiles mongoimport mongorestore mongos mongosniff mongostat mongotop}.each do |binary|
      FileUtils.install "/tmp/#{mongodb_package_basename}/bin/#{binary}", "#{enclosed_node[:mongodb][:prefix]}/bin", :mode => 0755
      FileUtils.chown "root", "root", "#{enclosed_node[:mongodb][:prefix]}/bin/#{binary}"
    end
  end
end

group node[:mongodb][:group] do
  action :create
end

user node[:mongodb][:user] do
  gid node[:mongodb][:group]
  home "/home/mongodb"
  # TODO: Decide whether to set "real" login shell and to create the homedir!
  shell "/bin/false"
  supports :manage_home => true
  action :create
end

directory node[:mongodb][:dbpath] do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
end

directory File.dirname(node[:mongodb][:logpath]) do
  action :create
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
end

