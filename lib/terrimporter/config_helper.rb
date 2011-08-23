require 'configuration'

module ConfigHelper

  def config_working_directory_path
    File.join(Dir.pwd, TerrImporter::Application::Configuration::CONFIG_DEFAULT_NAME)
  end

  def config_working_directory_exists?
    File.exists? config_working_directory_path
  end

  def config_example_path
    File.join(File.dirname(__FILE__), '..', '..', 'config', TerrImporter::Application::Configuration::CONFIG_DEFAULT_NAME)
  end

  def create_config_file(backup_or_replace = nil)
    case backup_or_replace
      when :backup
        FileUtils.mv(config_working_directory_path, config_working_directory_path + '.bak')
      when :replace
        FileUtils.rm_f config_working_directory_path if File.exists? config_working_directory_path
    end
    FileUtils.cp(config_example_path, config_working_directory_path)
  end

end