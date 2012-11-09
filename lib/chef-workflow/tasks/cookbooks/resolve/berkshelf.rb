load File.join(File.dirname(__FILE__), 'bootstrap.rb')

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
