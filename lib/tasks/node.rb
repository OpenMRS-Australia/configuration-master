require "capistrano"
require "capistrano/cli"
require "capistrano/configuration/variables"

namespace :node do

  desc "apply puppet infrastructure changes to target hosts"
  task :puppet_apply, [:noop] => ['clean', 'package:puppet'] do |task, args|
    settings = Ops::AWSSettings.load
    bootstrap_url = Ops::BootstrapPackage.new("#{BUILD_DIR}/#{BOOTSTRAP_FILE}", settings.bucket_name).url
    puppet_bootstrap = Ops::PuppetBootstrap.new(:role => "buildserver",
                                                :boot_package_url => bootstrap_url)
    cap :puppet_apply, :script => puppet_bootstrap.script, :noop => args[:noop]
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