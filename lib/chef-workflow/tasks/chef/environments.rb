require 'knife/dsl'
require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef do
  namespace :enviroments do
    desc "Upload your environments to the chef server"
    task :upload => [ "bootstrap:knife" ] do
      status = knife %W[environment from file] + Dir[File.join(KnifeSupport.singleton.environments_path, '*')]
      fail if status != 0
    end
  end
end
