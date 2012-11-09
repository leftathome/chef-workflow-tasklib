require 'chef-workflow/ip-support'
require 'chef-workflow/knife-support'
require 'chef-workflow/vagrant-support'

namespace :chef do
  desc "Show the calculated configuration for chef-workflow"
  task :show_config do
    puts "knife:"
    mute = %w[knife_config_template]
    KnifeSupport::DEFAULTS.keys.reject { |x| mute.include?(x.to_s) }.each do |key|
      puts "\t#{key}: #{KnifeSupport.singleton.send(key)}"
    end

    puts "vagrant:"
    puts "\tip subnet (/24): #{IPSupport.singleton.subnet}"
    puts "\tprison dir: #{VagrantSupport.singleton.prison_dir}"
    puts "\tbox url: #{VagrantSupport.singleton.box_url}"
  end
end
