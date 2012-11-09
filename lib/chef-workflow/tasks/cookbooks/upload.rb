require 'knife/dsl'
require 'chef-workflow/tasks/bootstrap/knife'

namespace :cookbooks do
  desc "Upload your cookbooks to the chef server"
  task :upload => [ "bootstrap:knife" ] do
    result = knife %W[cookbook upload -a]
    fail if result != 0
  end
end
