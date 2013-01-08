require 'knife/dsl'
require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef do
  namespace :environments do
    desc "Upload your environments to the chef server"
    task :upload => [ "bootstrap:knife" ] do
      if File.directory?(KnifeSupport.singleton.environments_path)
        status = knife %W[environment from file] + Dir[File.join(KnifeSupport.singleton.environments_path, '*.{rb,js,json}')]
        fail if status != 0
      end
    end
  end
end
