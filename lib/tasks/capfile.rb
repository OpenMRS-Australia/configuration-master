ENV["HOSTS"] = "ec2-50-112-42-202.us-west-2.compute.amazonaws.com"
set :user, "ec2-user"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

task :puppet_apply do
  put(script, "/tmp/update.sh", :mode => "0755")
  run("#{sudo} /tmp/update.sh")
end