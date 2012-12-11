require 'chef-workflow/tasks/test'
require 'chef-workflow/tasks/chef/upload'
require 'chef-workflow/tasks/chef/clean'

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
    "chef:upload"
  ]

  desc "test:refresh and test"
  task :build => [
    "test:refresh",
    "test"
  ]

  desc "chef:clean:machines and test:build"
  task :rebuild => [
    "chef:clean:machines",
    "test:build"
  ]

  desc "Build a chef server, run test:build, destroy the chef server"
  task :full => [
    "chef_server:create",
    "test:build",
    "chef:clean"
  ]
end
