require 'chef-workflow'

chef_workflow-task 'chef_server/vagrant'
chef_workflow-task 'cookbooks/upload'
chef_workflow-task 'chef/roles'
chef_workflow-task 'chef/environments'
chef_workflow-task 'chef/show_config'
chef_workflow-task 'chef/clean'
chef_workflow-task 'test/vagrant'

class Chef
  module Workflow
    module TaskHelper
      def chef_workflow_task(obj)
        require "chef-workflow/tasks/#{obj}"
      end
    end
  end
end

class << eval("self", TOPLEVEL_BINDING)
  include Chef::Workflow::TaskHelper
end

if defined? Rake::DSL
  module Rake::DSL
    include Chef::Workflow::TaskHelper
  end
end
