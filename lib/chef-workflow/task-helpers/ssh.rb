require 'chef-workflow/helpers/ssh'

if defined? Rake::DSL
  module Rake::DSL
    include SSHHelper
  end
end

class << eval('self', TOPLEVEL_BINDING)
  include SSHHelper
end
