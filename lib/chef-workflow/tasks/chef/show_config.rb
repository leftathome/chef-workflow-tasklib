require 'chef-workflow/support/general'
require 'chef-workflow/support/ip'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/vagrant'

namespace :chef do
  desc "Show the calculated configuration for chef-workflow"
  task :show_config do
    puts "general:"
    puts "\tworkflow_dir: #{GeneralSupport.singleton.workflow_dir}"
    puts "\tvm_file: #{GeneralSupport.singleton.vm_file}"
    puts "\tchef_server_prison: #{GeneralSupport.singleton.chef_server_prison}"
    puts "\tmachine_provisoner: #{GeneralSupport.singleton.machine_provisioner}"

    puts "knife:"
    mute = %w[knife_config_template]
    KnifeSupport::DEFAULTS.keys.reject { |x| mute.include?(x.to_s) }.each do |key|
      puts "\t#{key}: #{KnifeSupport.singleton.send(key)}"
    end

    puts "vagrant:"
    puts "\tip subnet (/24): #{IPSupport.singleton.subnet}"
    puts "\tbox url: #{VagrantSupport.singleton.box_url}"

    puts "ec2:"

    %w[
      ami
      instance_type
      region
      ssh_key
      security_groups
      security_group_open_ports
    ].each do |key|
      puts "\t#{key}: #{EC2Support.singleton.send(key)}"
    end
  end
end
