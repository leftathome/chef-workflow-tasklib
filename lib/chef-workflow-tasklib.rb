require 'chef-workflow'

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
