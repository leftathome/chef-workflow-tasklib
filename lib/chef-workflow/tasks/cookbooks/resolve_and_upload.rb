require 'chef-workflow/tasks/cookbooks/upload'

namespace :cookbooks do
  desc "Run the cookbook resolver and upload the result to the chef server."
  task :resolve_and_upload => [ "cookbooks:resolve", "cookbooks:upload" ] 
end
