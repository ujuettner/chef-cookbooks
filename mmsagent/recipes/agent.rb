remote_file "/tmp/10gen-mms-agent.tar.gz" do
  source "https://mms.10gen.com/settings/10gen-mms-agent.tar.gz"
end

execute "tar xvfz /tmp/10gen-mms-agent.tar.gz" do
  cwd "/tmp"
end

