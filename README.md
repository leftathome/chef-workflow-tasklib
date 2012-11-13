# Chef Workflow - Rake Tasks & Support

This gem provides a set of rake tasks broken up logically to support a chef
workflow, and tooling to assist with driving those tasks.

This suite of tools is an attempt to build a pragmatic workflow -- one that
does not assume how we work will be the "best" or only way to work. As a result
every attempt has been made to remain as flexible as possible to allow you to
take the parts you like, throw out what you don't, create what you want from
primitives, and customize what you want to keep.

We also provide a workflow-aware suite of test helpers to drive asserting the
state of a chef server, external requirements, full-stack testing, and
converging nodes in dynamically provisioned environment. Please see [Chef
Workflow - Test Support](https://github.com/hoteltonight/chef-workflow-testlib)
for more information on this sister project.

## Installation

Many of the design considerations behind chef-workflow depend on bundler.

Add this line to your application's Gemfile:

    gem 'chef-workflow-tasklib'

And then execute:

    $ bundle

To get started, create a Rakefile and include the base set of tasks (the
'default' workflow)

```ruby
require 'chef-workflow'
```

Then to see all the tasks use:

    $ bundle exec rake -T

**Note:** `rake` by itself will **not work**. We depend on newer gems than the
`rake` that's included with ruby does, which is what will be used if you do not
execute `bundle exec rake`. At this point bundler runs, it will fail because
`rake` will have activated gems that your bundle will be incompatible with.

You should see something similar to this:

```
rake chef:clean                      # Clean up the state files that chef-workflow generates
rake chef:clean:ips                  # Clean up the ip registry for chef-workflow
rake chef:clean:knife                # Clean up the temporary chef configuration for chef-workflow
rake chef:clean:prisons              # Clean up the prison registry for chef-workflow
rake chef:environments:upload        # Upload your environments to the chef server
rake chef:roles:upload               # Upload your roles to the chef server
rake chef:show_config                # Show the calculated configuration for chef-workflow
rake chef_server:build_knife_config  # Create and write a knife configuration suitable for creating new chef servers.
rake chef_server:create:vagrant      # Create a chef server in a vagrant machine.
rake chef_server:destroy:vagrant     # Destroy the last chef server created with vagrant
rake cookbooks:update                # Update your locked cookbooks with Berkshelf
rake cookbooks:upload                # Upload your cookbooks to the chef server
rake test                            # Run tests
rake test:build                      # test:refresh and test
rake test:refresh                    # Refresh all global meta on the chef server
rake test:vagrant:full               # Build a chef server with vagrant, run test:build, destroy the chef server
```

Last step: add `.chef-workflow` to `.gitignore`. You can configure this, but
until you've done that, it's going to write things to this directory.

If you want to do a full test run at this point (which with no tests will do
nothing but build a chef server and tear it down), feel free to:

    $ bundle exec test:vagrant:full

## Notes on dependencies

As of this writing, the workflow has some pretty strict requirements that we
hope to make more flexible in the near future. Until then, you should be aware
of a few things:

* Chef 10.16.2 is required. This isn't actually necessary as mentioned above,
  and will be resolved as soon as I can find time to test with earlier
  versions. This has some implications:

    * Tools like `berkshelf` and `librarian` and `foodcritic` (all add-ins to
      the normal workflow) have hard dependencies on earlier versions of chef.
      The tasks that integrate these take this into account, but **you must
      install the gems separately and manually to use them**.

* Ruby 1.9 is **required**. We will gladly accept patches to make it 1.8.7
  compatible, but 1.8.7 compatibility is not something we will be actively
  pursuing at this point.

## Usage

Everything is driven through usage of `rake`, with an emphasis on
cherry-picking tasks with `require` into your `Rakefile` and configuring them
with support configurators like `KnifeSupport` and `VagrantSupport`.

The next few sections will briefly cover the high-level design of the system.
For details, hit the
[wiki](https://github.com/hoteltonight/chef-workflow-tasklib/wiki).

## Picking your own workflow

Adding `require` statements to your workflow is the easiest way to get started.
We don't expect you to use a resolver, for example, but support both
[Berkshelf](https://github.com/RiotGames/Berkshelf) and
[librarian](https://github.com/applicationsonline/librarian) out of the box.
None of these are required in the default `chef-workflow` require.

Many tasks exist in our [tasks
directory](https://github.com/hoteltonight/chef-workflow-tasklib/tree/master/lib/chef-workflow/tasks)
and I strongly recommend poking through it if you're interested in fully
customizing your workflow. Every attempt has been made for each task library to
pull in everything it needs to operate which allows you to use each independent
portion without fear of missing essential code.

So to add `berkshelf` support, we add this to our Rakefile:

```ruby
require 'chef-workflow/tasks/cookbooks/resolve/berkshelf'
```

Which will add a few tasks, `cookbooks:resolve` and `cookbooks:update` and a
few dependencies. **Note:** due to the way many of these tools declare
dependencies, they must be installed independently of the bundle with `gem
install`. This is out of our control.

Anyhow, to rebuild our workflow in `chef-workflow`, we can just require several
tasks to pull the whole thing in.

For example let's say we just want to add:

  * resolving cookbooks with librarian
  * uploading cookbooks
  * uploading roles
  * uploading environments
  * a task that does all of these when we type `rake`

*You'll have to point this at your live chef configurations* (see the next
section), but your `Rakefile` would at first look something like this:

```ruby
require 'chef-workflow/tasks/cookbooks/resolve/librarian'
require 'chef-workflow/tasks/cookbooks/upload'
require 'chef-workflow/tasks/chef/roles'
require 'chef-workflow/tasks/chef/environments'

task :default => %w[
  cookbooks:resolve_and_upload
  chef:roles:upload
  chef:environments:upload
]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
