require 'chef-workflow/knife-support'

namespace :cookbooks do
  desc "Run the cookbooks in #{KnifeSupport.fc_cookbooks_path} through foodcritic"
  task :foodcritic do
    Rake::Task["cookbooks:resolve"].invoke rescue nil
    Bundler.with_clean_env do
      sh "foodcritic #{KnifeSupport.fc_cookbooks_path} #{KnifeSupport.fc_options.join(" ")}"
    end
  end
end
