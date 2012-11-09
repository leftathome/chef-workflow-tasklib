require 'knife/dsl'
require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef do
  namespace :roles do
    desc "Upload your roles (in #{KnifeSupport.roles_path}) to the chef server"
    task :upload => [ "bootstrap:knife" ] do
      status = knife %W[role from file] + Dir[File.join(KnifeSupport.roles_path, '*')]
      fail if status != 0
    end
  end
end
