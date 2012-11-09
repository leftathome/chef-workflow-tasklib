load File.join(File.dirname(__FILE__), 'bootstrap.rb')

# Both berkshelf and librarian have ... aggressive dependencies. They usually are
# a great way to break your Gemfile if you have chef in it.
namespace :cookbooks do
  desc "Resolve cookbooks and populate using Librarian"
  task :resolve => [ "bootstrap:knife" ] do
    Bundler.with_clean_env do
      sh "librarian-chef install --path #{KnifeSupport.singleton.cookbooks_path}"
    end
  end

  desc "Update your locked cookbooks with Librarian"
  task :update => [ "bootstrap:knife" ] do
    Bundler.with_clean_env do
      sh "librarian-chef update"
    end
  end
end
