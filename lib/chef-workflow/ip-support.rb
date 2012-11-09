require 'vagrant/dsl'
require 'delegate'
require 'chef-workflow/generic-support'

ENV["TEST_CHEF_SUBNET"] ||= "10.10.10.0"

class IPSupport < DelegateClass(Hash)
  attr_writer :subnet

  def initialize(subnet=ENV["TEST_CHEF_SUBNET"], ip_file=File.join(Dir.pwd, '.chef-workflow', 'ips'))
    @subnet = subnet
    reset
    @ip_file = ip_file
    super(@ip_assignment)
  end

  def subnet(ip=nil)
    if ip
      @subnet = ip
    end
    @subnet
  end

  def ip_file(filename=nil)
    if filename
      @ip_file = filename
    end
    @ip_file
  end

  def reset
    @ip_assignment = { }
  end

  def load
    if File.exist?(ip_file)
      @ip_assignment = Marshal.load(File.binread(ip_file))
    end
  end

  def write
    File.binwrite(ip_file, Marshal.dump(@ip_assignment))
  end

  def unused_ip
    ip = @subnet.next

    while ip_used?(ip)
      ip.next!
    end

    return ip
  end

  def ip_used?(ip)
    @ip_assignment.values.flatten.include?(ip)
  end

  def assign_role_ip(role, ip)
    @ip_assignment[role] ||= []
    @ip_assignment[role].push(ip)
  end

  def get_role_ips(role)
    @ip_assignment[role] || []
  end

  def seed_vagrant_ips
    # vagrant requires that .1 be used by vagrant. ugh.
    dot_one_ip = @subnet.gsub(/\.\d+$/, '.1')
    unless ip_used?(dot_one_ip)
      assign_role_ip("vagrant-reserved", dot_one_ip)
    end
  end

  include GenericSupport
end

IPSupport.configure
IPSupport.singleton.load

at_exit do
  IPSupport.singleton.write
end
