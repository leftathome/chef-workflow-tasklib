require 'chef-workflow/support/general'
require 'chef-workflow/support/ip'
require 'chef-workflow/support/vagrant'
require 'chef-workflow/support/ec2'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/scheduler'
require 'chef/config'

if defined? Rake::DSL
  module Rake::DSL 
    def with_scheduler(auto_save=false)
      if File.exist?(ChefWorkflow::KnifeSupport.singleton.knife_config_path)
        Chef::Config.from_file(ChefWorkflow::KnifeSupport.singleton.knife_config_path)
        s = ChefWorkflow::Scheduler.new(auto_save)
        yield s
        s.write_state
      end
    end
  end
end
