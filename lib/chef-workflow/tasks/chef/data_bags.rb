require 'knife/dsl'
require 'chef-workflow/tasks/bootstrap/knife'

namespace :chef do
  namespace :data_bags do
    desc "Upload your data bags to the chef server"
    task :upload => [ "bootstrap:knife" ] do
      if File.directory?(ChefWorkflow::KnifeSupport.singleton.data_bags_path)
        # bag names: basename of data_bags/*. This presumes your data bags path
        # is structured like so:
        #
        # data_bags/my_bag # bag name
        # data_bags/my_bag/my_item.(rb|json) # bag item
        #
        # note that while it makes an attempt to select by filename vs.
        # directory in the right spots. will probably blow up spectacularly
        # explode if you deviate heavily from this directory structure.
        #
        bag_names = Dir[File.join(ChefWorkflow::KnifeSupport.singleton.data_bags_path, "*")].
          select { |x| File.directory?(x) }.
          map { |x| File.basename(x) } 

        bag_names.each do |bag|
          status = knife %W[data bag create #{bag}]
          # XXX this doesn't fail if the data bag already exists.
          #     we're actually depending on this.
          fail if status != 0

          bag_items = Dir[File.join(ChefWorkflow::KnifeSupport.singleton.data_bags_path, bag, '*')].
            select { |x| !File.directory?(x) }
          status = knife %W[data bag from file #{bag}] + bag_items
          fail if status != 0
        end
      end
    end
  end
end
