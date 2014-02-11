set :user, "ec2-user"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

task :puppet_apply do
  put(script, "/tmp/update.sh", :mode => "0755")
  run("#{sudo} /tmp/update.sh")
end

task :deploy_omod do
  temp_dir = "/tmp/omod/libs"
  run("#{sudo} rm -rf #{temp_dir}")
  run("#{sudo} mkdir -p #{temp_dir}")
  run("#{sudo} chmod 777 #{temp_dir}")
  

  module_directory = "/usr/share/tomcat6/.OpenMRS/modules"

  # TODO: refactor by somebody who knows Ruby 
  # refer to node.rb
  #    cap :deploy_omod, :omod_file_review => [omod_file_review, omod_file_propose]
  
  # review
  tempfile = transfer_file "omod/libs/#{omod_file_review}"
  targetfile = "#{module_directory}/#{omod_file_review}"
  run("#{sudo} rm -f #{module_directory}/conceptreview*")
  run("#{sudo} mv #{tempfile} #{targetfile}")
  run("#{sudo} chown tomcat:tomcat #{targetfile}")
  run("#{sudo} chmod 0644 #{targetfile}")

  # propose
  tempfile = transfer_file "omod/libs/#{omod_file_propose}"
  targetfile = "#{module_directory}/#{omod_file_propose}"
  run("#{sudo} rm -f #{module_directory}/conceptpropose*")
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
