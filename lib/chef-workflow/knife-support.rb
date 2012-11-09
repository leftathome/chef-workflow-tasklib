class KnifeSupport
  CHEF_CONFIG_PATH  = File.join(Dir.pwd, '.chef')
  KNIFE_CONFIG_PATH = File.join(CHEF_CONFIG_PATH, 'knife.rb')
  KNIFE_CONFIG_TEMPLATE = <<-EOF
  log_level                :info
  log_location             STDOUT
  node_name                'test-user'
  client_key               File.join('<%= $knife_support.options[:chef_config_path] %>', 'admin.pem')
  validation_client_name   'chef-validator'
  validation_key           File.join('<%= $knife_support.options[:chef_config_path] %>', 'validation.pem')
  chef_server_url          'https://<%= $ip_assignment.get_role_ips("chef-server").first %>:443'
  cache_type               'BasicFile'
  EOF

  attr_accessor :options

  def initialize(options)
    [
      :chef_config_path, 
      :knife_config_path, 
      :knife_config_template
    ].each do |key|
      unless options[key]
        options[key] = const_get(key.to_s.upcase)
      end
    end

    @options = options
  end

  def build_knife_config
    FileUtils.mkdir_p(options[:chef_config_path])
    File.binwrite(options[:knife_config_path], ERB.new(options[:knife_config_template]).result(binding))
  end
end

$knife_support ||= KnifeSupport.new
