require 'chef-workflow/task-helpers/with_scheduler'
require 'fileutils'

namespace :chef do
  namespace :clean do
    desc "Clean up the ip registry for chef-workflow"
    task :ips do
      IPSupport.singleton.reset
      IPSupport.singleton.write
    end

    desc "Clean up the temporary chef configuration for chef-workflow"
    task :knife do
      FileUtils.rm_rf(KnifeSupport.singleton.chef_config_path)
      FileUtils.rm_f(KnifeSupport.singleton.knife_config_path)
    end

    desc "Clean up the machines that a previous chef-workflow run generated"
    task :machines do
      with_scheduler do |s|
        s.serial = true
        s.force_deprovision = true
        s.teardown(%w[chef-server])
      end
    end
  end

  desc "Clean up the entire chef-workflow directory and machines"
  task :clean => [ "chef:clean:machines", "chef_server:destroy" ] do
    EC2Support.singleton.destroy_security_group
    FileUtils.rm_rf(GeneralSupport.singleton.workflow_dir)
  end
end
