require 'chef-workflow/support/general'
require 'chef-workflow/support/ip'
require 'chef-workflow/support/vagrant'
require 'chef-workflow/support/ec2'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/scheduler'
require 'chef/config'

namespace :chef do
  desc "build and bootstrap a machine with a role in the run_list"
  task :build, :role_name, :number_of_machines do |task, args|
    unless args[:role_name]
      raise 'You must supply a role name to chef:build'
    end

    unless File.exist?(KnifeSupport.singleton.knife_config_path)
      raise 'Cannot find your knife.rb -- did you create a chef server?'
    end
  
    role_name          = args[:role_name]
    number_of_machines = (args[:number_of_machines] || 1).to_i

    Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)

    s = Scheduler.new(false)
    s.serial = true

    kp              = VM::KnifeProvisioner.new
    kp.username     = KnifeSupport.singleton.ssh_user
    kp.password     = KnifeSupport.singleton.ssh_password
    kp.use_sudo     = KnifeSupport.singleton.use_sudo
    kp.ssh_key      = KnifeSupport.singleton.ssh_identity_file
    kp.environment  = KnifeSupport.singleton.test_environment

    s.schedule_provision(
      role_name,
      [
        GeneralSupport.singleton.machine_provisioner.new(
          role_name,
          number_of_machines
        ),
        kp
      ],
      []
    )

    s.run
    s.wait_for(role_name)
    s.write_state
  end
end
