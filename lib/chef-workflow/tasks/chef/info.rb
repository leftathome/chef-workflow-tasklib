require 'chef-workflow/task-helpers/with_scheduler'
require 'chef-workflow/support/ip'

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
      IPSupport.singleton.roles.each do |role|
        puts "Group: #{role}"
        IPSupport.singleton.get_role_ips(role).each do |ip|
          puts "\t#{ip}"
        end
      end
    end
  end
end
