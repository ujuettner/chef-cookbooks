remote_file "/tmp/carbon-0.9.10.tar.gz" do
  source "https://launchpad.net/graphite/0.9/0.9.10/+download/carbon-0.9.10.tar.gz"
end

execute "tar xvfz /tmp/carbon-0.9.10.tar.gz" do
  cwd "/tmp"
end

