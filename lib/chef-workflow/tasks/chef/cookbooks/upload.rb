require 'knife/dsl'
require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef do
  namespace :cookbooks do
    desc "Upload your cookbooks to the chef server"
    task :upload => [ "bootstrap:knife" ] do
      resolve_task = Rake::Task["chef:cookbooks:resolve"] rescue nil
      resolve_task.invoke if resolve_task

      result = knife %W[cookbook upload -a]
      fail if result != 0
    end
  end
end
