remote_file "/tmp/graphite-web-0.9.10.tar.gz" do
  source "https://launchpad.net/graphite/0.9/0.9.10/+download/graphite-web-0.9.10.tar.gz"
end

remote_file "/tmp/check-dependencies.py" do
  source "https://launchpad.net/graphite/0.9/0.9.10/+download/check-dependencies.py"
end

execute "tar xvfz /tmp/graphite-web-0.9.10.tar.gz" do
  cwd "/tmp"
end

