require 'fileutils'
class VagrantSupport
  def initialize(prison_dir=File.join(Dir.pwd, '.prisons'))
    @prison_dir = prison_dir
  end

  def create_prison_dir
    FileUtils.mkdir_p(@prison_dir)
  end

  def qualify_prison_file(prison_file)
    File.join(@prison_dir, prison_file)
  end

  # TODO make Vagrant::Prison easier to recreate without rebuilding the Vagrantfile
  def write_prison(prison_file, prison)
    create_prison_dir
    File.binwrite(
      qualify_prison_file(prison_file),
      Marshal.dump([prison.dir, prison.env_opts])
    )
  end

  def read_prison(prison_file)
    prison_file = qualify_prison_file(prison_file)
    if File.exist?(prison_file)
      return Marshal.load(File.binread(prison_file))
    end

    return []
  end

  def remove_prison(prison_file)
    FileUtils.rm_f(qualify_prison_file(prison_file))
  end
end

$vagrant_support ||= VagrantSupport.new
