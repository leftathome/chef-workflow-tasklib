# used by resolver tasklibs to ensure their basic dependencies are met. Not to be used directly.
begin
  Rake::Task["cookbooks:resolve"].clear
  Rake::Task["cookbooks:update"].clear
rescue
end

require 'chef-workflow/tasks/bootstrap/knife'
require 'chef-workflow/tasks/cookbooks/resolve_and_upload'
