require 'fileutils'
require 'erb'

class KnifeSupport
  DEFAULTS = {
    :cookbooks_path         => File.join(Dir.pwd, 'cookbooks'),
    :chef_config_path       => File.join(Dir.pwd, '.chef'),
    :knife_config_path      => File.join(Dir.pwd, '.chef', 'knife.rb'),
  }

  DEFAULTS[:knife_config_template] = <<-EOF
  log_level                :info
  log_location             STDOUT
  node_name                'test-user'
  client_key               File.join('<%= $knife_support.chef_config_path %>', 'admin.pem')
  validation_client_name   'chef-validator'
  validation_key           File.join('<%= $knife_support.chef_config_path %>', 'validation.pem')
  chef_server_url          'https://<%= $ip_assignment.get_role_ips("chef-server").first %>:443'
  cache_type               'BasicFile'
  cache_options( :path => File.join('<%= $knife_support.chef_config_path %>', 'checksums' ))
  cookbook_path            [ '<%= $knife_support.cookbooks_path %>' ]
  EOF

  DEFAULTS.each_key do |key|
    attr_accessor key
  end

  def initialize(options={})
    DEFAULTS.each do |key, value|
      instance_variable_set(
        "@#{key}", 
        options.has_key?(key) ? options[key] : DEFAULTS[key]
      )
    end
  end

  def build_knife_config
    FileUtils.mkdir_p(chef_config_path)
    File.binwrite(knife_config_path, ERB.new(knife_config_template).result(binding))
  end
end

$knife_support ||= KnifeSupport.new
