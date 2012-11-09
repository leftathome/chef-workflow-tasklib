require 'knife/dsl'
require 'vagrant/dsl'
require 'erb'
require 'fileutils'

ENV["TEST_CHEF_SUBNET"] ||= "10.10.10.0"

$ip_assignment ||= Hash.new { |h,k| h[k] = [] } 

def unused_ip
  subnet = ENV["TEST_CHEF_SUBNET"].dup.next

  while ip_used?(subnet)
    subnet.next!
  end
  
  return subnet
end

def ip_used?(ip)
  $ip_assignment.values.flatten.include?(ip)
end

def assign_role_ip(role, ip)
  $ip_assignment[role].push(ip)
end

def get_role_ips(role)
  $ip_assignment[role]
end

def seed_vagrant_ips
  # vagrant requires that .1 be used by vagrant. ugh.
  dot_one_ip = ENV["TEST_CHEF_SUBNET"].gsub(/\.\d+$/, '.1')
  unless ip_used?(dot_one_ip)
    assign_role_ip("vagrant-reserved", dot_one_ip)
  end
end

# FIXME make this a temporary path later
KNIFE_CONFIG_PATH = File.join(Dir.pwd, 'knife.rb')

KNIFE_CONFIG_TEMPLATE = <<-EOF
log_level                :info
log_location             STDOUT
node_name                'test-user'
client_key               File.join(File.dirname(__FILE__), 'admin.pem')
validation_client_name   'chef-validator'
validation_key           File.join(File.dirname(__FILE__), 'validation.pem')
chef_server_url          'https://<%= get_role_ips("chef-server").first %>:443'
cache_type               'BasicFile'
EOF

CHEF_SERVER_PRISON_FILE = File.join(Dir.pwd, '.prisons', 'chef-server')

def build_knife_config(path=KNIFE_CONFIG_PATH)
  File.binwrite(path, ERB.new(KNIFE_CONFIG_TEMPLATE).result(binding))
end

namespace :chef_server do
  desc "Create and write a knife configuration to #{KNIFE_CONFIG_PATH} suitable for creating new chef servers."
  task :build_knife_config do
    build_knife_config
    ENV["CHEF_CONFIG"] = KNIFE_CONFIG_PATH # this is what knife-dsl needs to know what config to use
  end

  namespace :create do
    task :allocate_vagrant_ip do
      seed_vagrant_ips
      assign_role_ip("chef-server", unused_ip) 
    end

    desc "Create a chef server in a vagrant machine."
    task :vagrant => [ "chef_server:create:allocate_vagrant_ip", "chef_server:build_knife_config" ] do
      chef_server_ip = get_role_ips("chef-server").first
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
