load File.join(File.dirname(__FILE__), 'bootstrap.rb')

# Both berkshelf and librarian have ... aggressive dependencies. They usually are
# a great way to break your Gemfile if you have chef in it.
namespace :cookbooks do
  desc "Resolve cookbooks and populate using Berkshelf"
  task :resolve => [ "bootstrap:knife" ] do
    Bundler.with_clean_env do
      #
      # "hey guys, I've got an idea! There's absolutely no reason to change
      # this option, but let's do it anyway!"
      #
      # This code brought to you by the above thought.
      #
      system("gem list --local | grep -E '^berkshelf' | grep -qE '( ,|\\()1\\.0'")

      synonyms_are_hard_lets_go_shopping = $?.exitstatus == 0 ? "path" : "shims"
      sh "berks install --#{synonyms_are_hard_lets_go_shopping} #{KnifeSupport.singleton.cookbooks_path}"
    end
  end

  desc "Update your locked cookbooks with Berkshelf"
  task :update => [ "bootstrap:knife" ] do
    Bundler.with_clean_env do
      sh "berks update -c #{KnifeSupport.singleton.knife_config_path}"
    end
  end
end
