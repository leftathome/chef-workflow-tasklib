require 'chef-workflow/tasks/chef_server/vagrant'
require 'chef-workflow/tasks/test/build'
require 'chef-workflow/tasks/chef/clean'

namespace :test do
  namespace :vagrant do
    desc "Build a chef server with vagrant, run test:build, destroy the chef server"
    task :full => [ 
      "chef_server:create:vagrant", 
      "test:build",
      "chef:clean" # this actually tears down the chef server
    ]
  end
end
