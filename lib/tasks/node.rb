require "capistrano"
require "capistrano/cli"
require "capistrano/configuration/variables"

namespace :node do
  roles = {
    "ci-environment" => "buildserver",
    "autotest" => "appserver"
  }

  desc "apply puppet infrastructure changes to target hosts"
  task :update_ci, [:noop] => ['clean', 'test:puppet_syntax','package:puppet'] do |task, args|
    settings = Ops::AWSSettings.load
    ENV['HOSTS'] = Ops::Stacks.new("ci-environment").instances.collect {|i| i.url}.join(",")
    bootstrap_url = Ops::BootstrapPackage.new("#{BUILD_DIR}/#{BOOTSTRAP_FILE}", settings.bucket_name).url
    puppet_bootstrap = Ops::PuppetBootstrap.new(:role => "buildserver",
                                                :boot_package_url => bootstrap_url,
                                                :noop => args[:noop] == 'noop')
    cap :puppet_apply, :script => puppet_bootstrap.script
  end

  desc "update autotest environment"
  task :update_autotest => ['clean', 'test:puppet_syntax','package:puppet'] do |task, args|
    Ops::AWSSettings.load
    ENV['HOSTS'] = Ops::Stacks.new("autotest").instances.collect {|i| i.url}.join(",")
    bootstrap_url = Ops::BootstrapPackage.new("#{BUILD_DIR}/#{BOOTSTRAP_FILE}", settings.bucket_name).url
    puppet_bootstrap = Ops::PuppetBootstrap.new(:role => "appserver",
                                                :boot_package_url => bootstrap_url)
    cap :puppet_apply, :script => puppet_bootstrap.script
  end

  desc "update qa environment"
  task :update_qa => ['clean', 'test:puppet_syntax', 'package:puppet'] do |task, args|
    Ops::AWSSettings.load
    ENV['HOSTS'] = Ops::Stacks.new("qa").instances.collect {|i| i.url}.join(",")
    bootstrap_url = Ops::BootstrapPackage.new("#{BUILD_DIR}/#{BOOTSTRAP_FILE}", settings.bucket_name).url
    puppet_bootstrap = Ops::PuppetBootstrap.new(:role => "appserver",
                                                :boot_package_url => bootstrap_url)
    cap :puppet_apply, :script => puppet_bootstrap.script
  end

  task :deploy_omod, :nodename do |task, args|
    nodename = args[:nodename]

    ENV['HOSTS'] = nodename
    cap :deploy_omod, :omod_file => omod_file

    puts "OpenMRS has been updated - http://#{nodename}:8080/openmrs"
  end

  def omod_file
    Dir.entries("conceptpropose/build/libs").select{|f| f =~ /^cpm-1.0/}.first
  end

  desc "(Re-)Bootstrap keys for build agent access to nodes"
  task :key_bootstrap do
    Ops::AWSSettings.load

    bootstrap_go_agents keypair
    bootstrap_nodes keypair
  end

  def bootstrap_nodes keyname
    hosts = []
    ["autotest", "qa"].each do |env|
      hosts << Ops::Stacks.new(env).instances.collect {|i| i.url}
    end
    ENV['HOSTS'] = hosts.join(",")

    cap :add_to_authorized_keys, :keyfile => "#{keyname}.pub"
  end

  def bootstrap_go_agents keyname
    go_agent = Ops::Stacks.new("ci-environment").instances.find { |i| i.name == "go-server" }
    ENV['HOSTS'] = go_agent.url

    cap :copy_private_key, :keyfile => keyname
  end

  def keypair
    default_keyname = "cpmbuild_id_rsa"
    return default_keyname if File.exists?("#{default_keyname}")

    sh "ssh-keygen -q -N '' -t rsa -b 2048 -f #{default_keyname}"

    return default_keyname
  end

  def cap(task, *args)
    parameters = ["-f", "#{File.dirname(__FILE__)}/capfile.rb"]
    parameters << task.to_s
    unless args.empty?
      parameters = parameters.concat(args.first.map { |key, value| ["-s", "#{key}=#{value}"] }.flatten)
    end
    Capistrano::CLI.parse(parameters).execute!
  end
end