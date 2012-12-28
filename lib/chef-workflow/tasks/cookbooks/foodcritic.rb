require 'chef-workflow/support/knife'

ChefWorkflow::KnifeSupport.add_attribute :fc_cookbooks_path, File.join(Dir.pwd, 'cookbooks')
ChefWorkflow::KnifeSupport.add_attribute :fc_options, [ ]

namespace :cookbooks do
  desc "Run the cookbooks through foodcritic"
  task :foodcritic do
    Rake::Task["cookbooks:resolve"].invoke rescue nil
    if File.directory?(ChefWorkflow::KnifeSupport.singleton.fc_cookbooks_path)
      Bundler.with_clean_env do
        sh "foodcritic #{ChefWorkflow::KnifeSupport.singleton.fc_cookbooks_path} #{ChefWorkflow::KnifeSupport.singleton.fc_options.join(" ")}"
      end
    end
  end
end
