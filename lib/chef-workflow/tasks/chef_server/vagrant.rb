require 'knife/dsl'
require 'vagrant/dsl'
require 'erb'
require 'fileutils'

require 'chef-workflow/ip-support'
require 'chef-workflow/knife-support'

CHEF_SERVER_PRISON_FILE = File.join(Dir.pwd, '.prisons', 'chef-server')

namespace :chef_server do
  desc "Create and write a knife configuration to #{KNIFE_CONFIG_PATH} suitable for creating new chef servers."
  task :build_knife_config do
    $knife_support.build_knife_config
    ENV["CHEF_CONFIG"] = $knife_support.options[:knife_config_path] # this is what knife-dsl needs to know what config to use
  end

  namespace :create do
    task :allocate_vagrant_ip do
      $ip_assignment.seed_vagrant_ips
      $ip_assignment.assign_role_ip("chef-server", unused_ip) 
    end

    desc "Create a chef server in a vagrant machine."
    task :vagrant => [ "chef_server:create:allocate_vagrant_ip", "chef_server:build_knife_config" ] do
      chef_server_ip = $ip_assignment.get_role_ips("chef-server").first
      prison = vagrant_prison(:auto_destroy => false) do
                 configure do |config|
                   config.vm.box = "ubuntu"
                   config.vm.define :test_chef_server, :primary => true do |this_config|
                     this_config.vm.network :hostonly, chef_server_ip
                   end
                 end

                 vagrant_up
               end

      FileUtils.mkdir_p(File.dirname(CHEF_SERVER_PRISON_FILE))
      File.binwrite(CHEF_SERVER_PRISON_FILE, Marshal.dump([prison.dir, prison.env_opts]))
      result = knife %W[server bootstrap standalone --ssh-user vagrant --node-name test-chef-server --host #{chef_server_ip} -P vagrant]

      fail if result > 0
    end
  end

  namespace :destroy do
    desc "Destroy the last chef server created with vagrant"
    task :vagrant do
      if File.exist?(CHEF_SERVER_PRISON_FILE)
        prison_dir, prison_env_opts = Marshal.load(File.binread(CHEF_SERVER_PRISON_FILE))
        Vagrant::Prison.cleanup(prison_dir, Vagrant::Environment.new(prison_env_opts))
        FileUtils.rm_f(CHEF_SERVER_PRISON_FILE)
      end
    end
  end
end
