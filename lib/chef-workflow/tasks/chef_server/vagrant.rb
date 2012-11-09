require 'knife/dsl'
require 'vagrant/dsl'
require 'erb'
require 'fileutils'

require 'chef-workflow/ip-support'
require 'chef-workflow/knife-support'
require 'chef-workflow/vagrant-support'

namespace :chef_server do
  desc "Create and write a knife configuration to #{$knife_support.options[:knife_config_path]} suitable for creating new chef servers."
  task :build_knife_config do
    $knife_support.build_knife_config

    # this is what knife-dsl needs to know what config to use
    ENV["CHEF_CONFIG"] = $knife_support.options[:knife_config_path]
  end

  namespace :create do
    task :allocate_vagrant_ip do
      $ip_assignment.seed_vagrant_ips
      $ip_assignment.assign_role_ip("chef-server", $ip_assignment.unused_ip) 
    end

    desc "Create a chef server in a vagrant machine."
    task :vagrant => [ "chef_server:create:allocate_vagrant_ip", "chef_server:build_knife_config" ] do
      chef_server_ip = $ip_assignment.get_role_ips("chef-server").first
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

      fail if result > 0
    end
  end

  namespace :destroy do
    desc "Destroy the last chef server created with vagrant"
    task :vagrant do
      prison_dir, prison_env_opts = $vagrant_support.read_prison('chef-server')

      if prison_dir and prison_env_opts
        Vagrant::Prison.cleanup(prison_dir, Vagrant::Environment.new(prison_env_opts))
        $vagrant_support.remove_prison('chef-server')
      end
    end
  end
end
