
module ConfigHelper

  def config_default_name
    'terrimporter.config.yml'
  end

  def schema_default_name
    'schema.yml'
  end

  def config_working_directory_path
    File.expand_path config_default_name
  end

  def config_working_directory_exists?
    File.exists? config_working_directory_path
  end

  def config_example_path
    File.join(base_config_path, config_default_name)
  end

  def schema_file_path
    File.join(base_config_path, schema_default_name)
  end

  def create_config_file(backup_or_replace = nil)
    case backup_or_replace
      when :backup
        FileUtils.mv(config_working_directory_path, config_working_directory_path + '.bak')
      when :replace
        FileUtils.rm_f(config_working_directory_path) if File.exists? config_working_directory_path
    end
    FileUtils.cp(config_example_path, config_working_directory_path)
  end

  private
  def base_config_path
    File.join(File.dirname(__FILE__), '..', '..', 'config')
  end

end