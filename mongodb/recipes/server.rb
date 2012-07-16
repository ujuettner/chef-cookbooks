remote_file "/tmp/mongodb-linux-i686-#{node[:mongodb][:version]}.tgz" do
  source "http://fastdl.mongodb.org/linux/mongodb-linux-i686-#{node[:mongodb][:version]}.tgz"
end

remote_file "/tmp/mongodb-linux-x86_64-#{node[:mongodb][:version]}.tgz" do
  source "http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-#{node[:mongodb][:version]}.tgz"
end

execute "tar xvfz /tmp/mongodb-linux-i686-#{node[:mongodb][:version]}.tgz" do
  cwd "/tmp"
end

execute "tar xvfz /tmp/mongodb-linux-x86_64-#{node[:mongodb][:version]}.tgz" do
  cwd "/tmp"
end

enclosed_node = node
ruby_block "Install binaries" do
  block do
    if enclosed_node[:instance][:architecture] == "i386"
      archive_dir = "mongodb-linux-i686-#{enclosed_node[:mongodb][:version]}"
    else
      archive_dir = "mongodb-linux-x86_64-#{enclosed_node[:mongodb][:version]}"
    end
    %w{bsondump mongo mongod mongodump mongoexport mongofiles mongoimport mongorestore mongos mongosniff mongostat mongotop}.each do |binary|
      FileUtils.install "/tmp/#{archive_dir}/bin/#{binary}",
                        "#{enclosed_node[:mongodb][:prefix]}/bin", :mode => 0755
      FileUtils.chown "root", "root", "#{enclosed_node[:mongodb][:prefix]}/bin/#{binary}"
    end
  end
end

group node[:mongodb][:group] do
  members node[:mongodb][:user]
  action :create
end

user node[:mongodb][:user] do
  shell "/bin/false"
  gid node[:mongodb][:gid]
  action :create
end

directory node[:mongodb][:dbpath] do
  owner node[:mongodb][:user]
  owner node[:mongodb][:group]
  mode "0755"
end

directory File.dirname(node[:mongodb][:logpath]) do
  action :create
  owner node[:mongodb][:user]
  owner node[:mongodb][:group]
  mode "0755"
end

