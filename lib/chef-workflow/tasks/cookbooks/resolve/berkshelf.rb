begin
  Rake::Task["cookbooks:resolve"].clear
  Rake::Task["cookbooks:update"].clear
rescue
end

require 'chef-workflow/tasks/bootstrap/knife'
require 'chef-workflow/tasks/cookbooks/resolve_and_upload'

# Both berkshelf and librarian have ... aggressive dependencies. They usually are
# a great way to break your Gemfile if you have chef in it.
namespace :cookbooks do
  desc "Resolve cookbooks and populate #{KnifeSupport.cookbooks_path} using Berkshelf"
  task :resolve => [ "bootstrap:knife" ] do
    Bundler.with_clean_env do
      sh "berks install --shims #{KnifeSupport.cookbooks_path} -c #{KnifeSupport.knife_config_path}"
    end
  end

  desc "Update your locked cookbooks with Berkshelf"
  task :update => [ "bootstrap:knife" ] do
    Bundler.with_clean_env do
      sh "berks update -c #{KnifeSupport.knife_config_path}"
    end
  end
end
