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

  def cap(task, *args)
    parameters = ["-f", "#{File.dirname(__FILE__)}/capfile.rb"]
    parameters << task.to_s
    unless args.empty?
      parameters = parameters.concat(args.first.map { |key, value| ["-s", "#{key}=#{value}"] }.flatten)
    end
    Capistrano::CLI.parse(parameters).execute!
  end

end