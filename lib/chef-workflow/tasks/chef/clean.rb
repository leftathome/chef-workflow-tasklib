require 'chef-workflow/ip-support'
require 'chef-workflow/vagrant-support'
require 'chef-workflow/knife-support'
require 'fileutils'

namespace :chef do
  namespace :clean do
    desc "Clean up the ip registry for chef-workflow"
    task :ips do
      IPSupport.singleton.reset
      IPSupport.singleton.write
    end

    desc "Clean up the prison registry for chef-workflow"
    task :prisons do
      FileUtils.rm_rf(VagrantSupport.singleton.prison_dir)
    end

    desc "Clean up the temporary chef configuration for chef-workflow"
    task :knife do
      FileUtils.rm_rf(KnifeSupport.singleton.chef_config_path)
      FileUtils.rm_f(KnifeSupport.singleton.knife_config_path)
    end
  end

  desc "Clean up the state files that chef-workflow generates"
  task :clean => [ "chef:clean:ips", "chef:clean:prisons", "chef:clean:knife" ]
end
