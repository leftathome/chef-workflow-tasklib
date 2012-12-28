require 'chef-workflow/task-helpers/with_scheduler'
require 'chef-workflow/support/ip'
require 'chef-workflow/support/general'
require 'chef-workflow/support/ip'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/vagrant'

namespace :chef do
  namespace :info do
    desc "Output some information about provisioned machines"
    task :provisioned do
      with_scheduler(false) do |s|
        s.vm_groups.each do |key, values|
          puts "Group: #{key}"
          values.each do |value|
            puts "\t#{value.class.name} provisioner:"
            value.report.each do |line|
              puts "\t\t#{line}"
            end
          end
        end
      end
    end

    desc "Output some information about known IP allocations"
    task :ips do
      ChefWorkflow::IPSupport.singleton.roles.each do |role|
        puts "Group: #{role}"
        ChefWorkflow::IPSupport.singleton.get_role_ips(role).each do |ip|
          puts "\t#{ip}"
        end
      end
    end

    desc "Show the calculated configuration for chef-workflow"
    task :config do
      puts "general:"
      puts "\tworkflow_dir: #{ChefWorkflow::GeneralSupport.singleton.workflow_dir}"
      puts "\tvm_file: #{ChefWorkflow::GeneralSupport.singleton.vm_file}"
      puts "\tchef_server_prison: #{ChefWorkflow::GeneralSupport.singleton.chef_server_prison}"
      puts "\tmachine_provisoner: #{ChefWorkflow::GeneralSupport.singleton.machine_provisioner}"

      puts "knife:"
      mute = %w[knife_config_template]
      ChefWorkflow::KnifeSupport::DEFAULTS.keys.reject { |x| mute.include?(x.to_s) }.each do |key|
        puts "\t#{key}: #{ChefWorkflow::KnifeSupport.singleton.send(key)}"
      end

      puts "vagrant:"
      puts "\tip subnet (/24): #{ChefWorkflow::IPSupport.singleton.subnet}"
      puts "\tbox url: #{ChefWorkflow::VagrantSupport.singleton.box_url}"

      puts "ec2:"

      %w[
        ami
        instance_type
        region
        ssh_key
        security_groups
        security_group_open_ports
      ].each do |key|
        puts "\t#{key}: #{ChefWorkflow::EC2Support.singleton.send(key)}"
      end
    end
  end
end
