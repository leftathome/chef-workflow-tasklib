chef_workflow_task 'chef_server'
chef_workflow_task 'chef/upload'

namespace :chef do
  desc "Create a new chef server and fill it with the chef repository."
  task :init => %w[chef_server:create chef:upload]
end
