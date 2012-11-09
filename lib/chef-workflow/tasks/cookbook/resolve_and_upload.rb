require 'chef-workflow/tasks/cookbook/upload'

namespace :cookbook do
  desc "Run the cookbook resolver and upload the result to the chef server."
  task :resolve_and_upload => [ "cookbook:resolve", "cookbook:upload" ] 
end
