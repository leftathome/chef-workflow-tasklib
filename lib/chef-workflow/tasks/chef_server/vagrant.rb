require 'knife/dsl'
require 'vagrant/dsl'

require 'chef-workflow/ip-support'
require 'chef-workflow/knife-support'
require 'chef-workflow/vagrant-support'

require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef_server do
  desc "Create and write a knife configuration to #{KnifeSupport.knife_config_path} suitable for creating new chef servers."
  task :build_knife_config do
    KnifeSupport.build_knife_config
    Rake::Task["bootstrap:knife"].invoke
  end

  namespace :create do
    task :allocate_vagrant_ip do
      IPSupport.singleton.seed_vagrant_ips
      IPSupport.singleton.assign_role_ip("chef-server", IPSupport.singleton.unused_ip) 
    end

    desc "Create a chef server in a vagrant machine."
    task :vagrant => [ "chef_server:create:allocate_vagrant_ip", "chef_server:build_knife_config" ] do
      chef_server_ip = IPSupport.singleton.get_role_ips("chef-server").first
      prison = vagrant_prison(:auto_destroy => false) do
                 configure do |config|
                   config.vm.box_url = $vagrant_support.box_url
                   config.vm.box = $vagrant_support.box
                   config.vm.define :test_chef_server, :primary => true do |this_config|
                     this_config.vm.network :hostonly, chef_server_ip
                   end
                 end

                 vagrant_up
               end

      $vagrant_support.write_prison('chef-server', prison)
      result = knife %W[server bootstrap standalone --ssh-user vagrant --node-name test-chef-server --host #{chef_server_ip} -P vagrant]

      fail if result != 0
    end
  end

  namespace :destroy do
    desc "Destroy the last chef server created with vagrant"
    task :vagrant do
      $vagrant_support.destroy_prison('chef-server')
    end
  end
end
