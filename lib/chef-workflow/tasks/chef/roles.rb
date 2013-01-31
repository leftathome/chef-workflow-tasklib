require 'knife/dsl'
require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef do
  namespace :roles do
    desc "Upload your roles to the chef server"
      if File.directory?(ChefWorkflow::KnifeSupport.singleton.roles_path)
        status = knife %W[role from file] + Dir[File.join(KnifeSupport.singleton.roles_path, '*.{rb,js,json}')]
        fail if status != 0
      end
    end
  end
end
