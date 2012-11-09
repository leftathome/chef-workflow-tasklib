require 'fileutils'
require 'erb'
require 'forwardable'
require 'chef-workflow/generic-support'

class KnifeSupport
  DEFAULTS = {
    :cookbooks_path         => File.join(Dir.pwd, 'cookbooks'),
    :chef_config_path       => File.join(Dir.pwd, '.chef-workflow', 'chef'),
    :knife_config_path      => File.join(Dir.pwd, '.chef-workflow', 'chef', 'knife.rb'),
    :roles_path             => File.join(Dir.pwd, 'roles'),
    :environments_path      => File.join(Dir.pwd, 'environments')
  }

  DEFAULTS[:knife_config_template] = <<-EOF
  log_level                :info
  log_location             STDOUT
  node_name                'test-user'
  client_key               File.join('<%= KnifeSupport.chef_config_path %>', 'admin.pem')
  validation_client_name   'chef-validator'
  validation_key           File.join('<%= KnifeSupport.chef_config_path %>', 'validation.pem')
  chef_server_url          'https://<%= IPSupport.singleton.get_role_ips("chef-server").first %>:443'
  cache_type               'BasicFile'
  cache_options( :path => File.join('<%= KnifeSupport.chef_config_path %>', 'checksums' ))
  cookbook_path            [ '<%= KnifeSupport.cookbooks_path %>' ]
  EOF

  DEFAULTS.each_key do |key|
    attr_writer key
    class_eval <<-EOF
      def #{key}(arg=nil)
        if arg
          @#{key} = arg
        end

        @#{key}
      end
    EOF
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

  include GenericSupport

  class << self
    extend Forwardable
    def_delegators :@singleton, :build_knife_config, *DEFAULTS.keys
  end
end

KnifeSupport.configure
