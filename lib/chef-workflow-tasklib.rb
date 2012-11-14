require 'chef-workflow'

require 'chef-workflow/tasks/chef_server/vagrant'
require 'chef-workflow/tasks/cookbooks/upload'
require 'chef-workflow/tasks/chef/roles'
require 'chef-workflow/tasks/chef/environments'
require 'chef-workflow/tasks/chef/show_config'
require 'chef-workflow/tasks/chef/clean'
require 'chef-workflow/tasks/test/vagrant'

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
