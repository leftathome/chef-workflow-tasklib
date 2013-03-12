require 'chef-workflow/task-helpers/with_scheduler'
require 'chef-workflow/support/vm/helpers/knife'

namespace :chef do
  desc "Tear down a server group"
  task :destroy, :role_name do |task, args|
    task.reenable

    unless args[:role_name]
      raise 'You must supply a role name to chef:destroy'
    end

    role_name = args[:role_name]

    with_scheduler do |s|
      s.teardown_group(role_name)
    end
  end
end
