require 'chef-workflow/support/general'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/scheduler'

namespace :chef_server do
  desc "Create a chef server with the #{GeneralSupport.singleton.machine_provisioner} provisioner"
  task :create do
    # FIXME not really happy with having to repeat this at the end, but it's
    # necessary. maybe a subroutine in the right place in the future is the
    # best approach, but I'm feeling lazy right now.
    KnifeSupport.singleton.build_knife_config
    Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)

    s = Scheduler.new(false)
    s.serial = true

    s.schedule_provision(
      'chef-server', 
      [
        GeneralSupport.singleton.machine_provisioner.new('chef-server', 1), 
        VM::ChefServerProvisioner.new
      ],
      []
    )

    s.run
    s.wait_for('chef-server') # probably superfluous
    s.write_state

    KnifeSupport.singleton.build_knife_config
    Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)
  end

  desc "Destroy the chef server"
  task :destroy do
    s = Scheduler.new(false)
    s.serial = true
    s.force_deprovision = true
    s.teardown_group('chef-server')
  end
end
