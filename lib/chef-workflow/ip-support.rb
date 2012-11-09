require 'vagrant/dsl'
require 'delegate'

ENV["TEST_CHEF_SUBNET"] ||= "10.10.10.0"

class IPSupport < DelegateClass(Hash)
  def initialize(subnet=ENV["TEST_CHEF_SUBNET"])
    @subnet = subnet
    @ip_assignment = Hash.new { |h,k| h[k] = [] }
    super(@ip_assignment)
  end

  def unused_ip
    ip = ENV["TEST_CHEF_SUBNET"].dup.next

    while ip_used?(ip)
      ip.next!
    end

    return ip
  end

  def ip_used?(ip)
    @ip_assignment.values.flatten.include?(ip)
  end

  def assign_role_ip(role, ip)
    @ip_assignment[role].push(ip)
  end

  def get_role_ips(role)
    @ip_assignment[role]
  end

  def seed_vagrant_ips
    # vagrant requires that .1 be used by vagrant. ugh.
    dot_one_ip = @subnet.gsub(/\.\d+$/, '.1')
    unless ip_used?(dot_one_ip)
      assign_role_ip("vagrant-reserved", dot_one_ip)
    end
  end
end

$ip_assignment ||= IPSupport.new