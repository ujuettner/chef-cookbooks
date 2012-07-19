remote_file "/tmp/whisper-0.9.10.tar.gz" do
  source "https://launchpad.net/graphite/0.9/0.9.10/+download/whisper-0.9.10.tar.gz"
end

execute "tar xvfz /tmp/whisper-0.9.10.tar.gz" do
  cwd "/tmp"
end

