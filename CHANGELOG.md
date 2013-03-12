* 0.2.2 March 12, 2012
  * New tasks:
    * `chef:init` creates a chef server and fills it with your chef repository.
      Shorthand for `chef_server:create chef:upload`.
    * `chef:destroy` is the inverse of `chef:build` and can be used to snipe
      server groups. Requires a role/group name and deprovisions them through
      the common path.
  * When cookbook resolvers were used and exited non-zero, the exit got
    swallowed and processing continued. They now abort like they should.
  * `chef:build`, `chef:converge`, and `chef:destroy` are now repeatable tasks,
    so you can do things like this: `be rake chef:build[foo] chef:build[bar]`
    and it does what you expect it to do.
* 0.2.1 February 11, 2012
  * A few common situations would cause cookbook resolvers to not work if they
    were integrated.
* 0.2.0 February 8, 2012
  * **breaking change**: the 'cookbooks' namespace has been moved to chef:cookbooks
  * chef:build builds a server or set of servers based on a server group. Uses
    the provisioner and scheduler, and is tracked no differently than
    provisions from tests or the chef server.
  * task helpers: with_scheduler and all the bits from SSHHelper in testlib are now available to rake tasks.
  * chef:converge, given a server group runs chef-client on it.
  * chef:info namespace created:
    * chef:show_config is now chef:info:config
    * chef:info:ips shows external IP assignments by server group
    * chef:info:provisioned shows information about the provisioned machines
  * Tasks have been re-written to exploit the refactors in chef-workflow
  * test:full task has some different semantics which make it more suitable for CI:
    * test:recipes is a part of the dependency list
    * always runs chef:clean before doing anything
  * If a resolver is used, `chef:upload` always invokes it before doing anything

* 0.1.1 December 21, 2012
  * Fix gemspec. Here's to touching the stove.

* 0.1.0 December 21, 2012
  * Initial public release
