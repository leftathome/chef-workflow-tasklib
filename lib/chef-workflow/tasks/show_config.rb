require 'chef-workflow/ip-support'
require 'chef-workflow/knife-support'
require 'chef-workflow/vagrant-support'

desc "Show the calculated configuration for chef-workflow"
task :show_config do
  puts "knife:"
  %w[cookbooks_path chef_config_path knife_config_path roles_path environments_path].each do |key|
    puts "\t#{key}: #{KnifeSupport.send(key)}"
  end

  puts "vagrant:"
  puts "\tip subnet (/24): #{IPSupport.singleton.subnet}"
  puts "\tprison dir: #{$vagrant_support.prison_dir}"
  puts "\tbox url: #{$vagrant_support.box_url}"
end
