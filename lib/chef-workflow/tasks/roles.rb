require 'chef-workflow/tasks/bootstrap/knife'

namespace :roles do
  desc "Upload your roles (in #{$knife_support.roles_path}) to the chef server"
  task :upload => [ "bootstrap:knife" ] do
    status = knife %W[role from file] + Dir[File.join($knife_support.roles_path, '*')]
    fail if status != 0
  end
end
