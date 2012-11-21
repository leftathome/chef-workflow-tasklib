require 'knife/dsl'
require 'vagrant/dsl'

require 'chef-workflow/support/ip'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/vagrant'

require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef_server do
  desc "Create and write a knife configuration suitable for creating new chef servers."
  task :build_knife_config do
    KnifeSupport.singleton.build_knife_config
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
                   config.vm.box_url = VagrantSupport.singleton.box_url
                   config.vm.box = VagrantSupport.singleton.box
                   config.vm.define :test_chef_server, :primary => true do |this_config|
                     this_config.vm.network :hostonly, chef_server_ip
                   end
                 end

                 vagrant_up
               end

      File.binwrite(GeneralSupport.singleton.chef_server_prison, Marshal.dump(prison))
      result = knife %W[server bootstrap standalone --ssh-user vagrant --node-name test-chef-server --host #{chef_server_ip} -P vagrant]

      fail if result != 0
    end
  end

  namespace :destroy do
    desc "Destroy the last chef server created with vagrant"
    task :vagrant do
      prison = Marshal.load(File.binread(GeneralSupport.singleton.chef_server_prison))
      prison.cleanup
      IPSupport.singleton.delete_role('chef-server')
    end
  end
end

# hooking for chef:clean
namespace :chef do
  namespace :clean do
    task :server => ["chef_server:destroy:vagrant"]
  end
end
