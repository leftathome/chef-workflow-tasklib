require 'rake/testtask'
require 'chef-workflow/task-helpers/with_scheduler'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir["test/**/test_*.rb"]
  t.verbose = true
end

namespace :test do
  desc "Test recipes in the test_recipes configuration."

  task :recipes => [ "recipes:cleanup" ] do
    with_scheduler do |s|
      s.run

      groups =
        KnifeSupport.singleton.test_recipes.map do |recipe|
        group_name = "recipe-#{recipe.gsub(/::/, '-')}"

        kp              = VM::KnifeProvisioner.new
        kp.username     = KnifeSupport.singleton.ssh_user
        kp.password     = KnifeSupport.singleton.ssh_password
        kp.use_sudo     = KnifeSupport.singleton.use_sudo
        kp.ssh_key      = KnifeSupport.singleton.ssh_identity_file
        kp.environment  = KnifeSupport.singleton.test_environment
        kp.run_list     = [ "recipe[#{recipe}]", "recipe[minitest-handler]" ]
        kp.solr_check   = false

        s.schedule_provision(
          group_name,
          [
            GeneralSupport.singleton.machine_provisioner.new(group_name, 1),
            kp
        ]
        )

        group_name
        end

      s.wait_for(*groups)

      groups.each do |group_name|
        s.teardown_group(group_name)
      end
    end
  end

  namespace :recipes do
    desc "Cleanup any stale instances created running recipe tests."
    task :cleanup do
      with_scheduler(true) do |s|
        s.run

        s.vm_groups.select do |g, v|
          g.start_with?("recipe-")
        end.each do |g, v|
          s.teardown_group(g, false)
        end
      end
    end
  end
end
