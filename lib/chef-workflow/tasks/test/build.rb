require 'chef-workflow/tasks/test'
require 'chef-workflow/tasks/cookbooks/upload'
require 'chef-workflow/tasks/chef/roles'
require 'chef-workflow/tasks/chef/environments'

namespace :test do
  task :resolve_hack do
    begin
      Rake::Task["cookbooks:resolve"].invoke
    rescue
    end
  end

  desc "Refresh all global meta on the chef server"
  task :refresh => [
    "test:resolve_hack",
    "cookbooks:upload",
    "chef:roles:upload",
    "chef:environments:upload"
  ]

  desc "test:refresh and test"
  task :build => [
    "test:refresh",
    "test"
  ]
end
