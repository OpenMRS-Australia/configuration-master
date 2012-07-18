set :user, "ec2-user"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

task :puppet_apply do
  put(script, "/tmp/update.sh", :mode => "0755")
  run("#{sudo} /tmp/update.sh")
end

task :deploy_omod do
  temp_dir = "/tmp/omod/target"
  run("#{sudo} rm -rf #{temp_dir}")
  run("#{sudo} mkdir -p #{temp_dir}")
  run("#{sudo} chmod 777 #{temp_dir}")

  tempfile = transfer_file "omod/target/#{omod_file}"

  module_directory = "/usr/share/tomcat6/.OpenMRS/modules"
  targetfile = "#{module_directory}/#{omod_file}"
  run("#{sudo} rm -f #{module_directory}/cpm*")
  run("#{sudo} mv #{tempfile} #{targetfile}")
  run("#{sudo} chown tomcat:tomcat #{targetfile}")
  run("#{sudo} chmod 0644 #{targetfile}")
  run("#{sudo} /sbin/service tomcat6 restart")
end

task :copy_private_key do
  tempfile = transfer_file keyfile
  targetfile = "/var/go/.ssh/#{keyfile}"

  run("#{sudo} mv #{tempfile} #{targetfile}")
  run("#{sudo} chown go:go #{targetfile}")
  run("#{sudo} chmod 0600 #{targetfile}")
end

task :add_to_authorized_keys do
  tempfile = transfer_file keyfile

  # TODO: be smarter about adding lines
  run("cat #{tempfile} >> ~/.ssh/authorized_keys")
  run("rm #{tempfile}")
end

def transfer_file file
  remotefile = "/tmp/#{file}"
  put(File.open(file, "r").read, remotefile)

  return remotefile
end
