module ConfigurationHelper

  def config_default_name
    'terrimporter.yml'
  end

  def schema_default_name
    'schema.yml'
  end

  def config_search_paths
    [
        Dir.pwd,
        File.join(Dir.pwd, 'config'),
        File.join(Dir.pwd, '.config'),
    ]
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

  def backup_config_file
    LOG.debug "Backing up old configuration file to #{config_working_directory_path}.bak"
    FileUtils.mv(config_working_directory_path, config_working_directory_path + '.bak')
  end

  def remove_config_file
    LOG.debug "Removing old configuration file"
    FileUtils.rm_f(config_working_directory_path) if File.exists? config_working_directory_path
  end

  def create_config_file(application_url = nil)
    LOG.info "Creating configuration file..."
    FileUtils.cp(config_example_path, config_working_directory_path)

    unless application_url.nil?
      configuration = File.read(config_working_directory_path)
      configuration.gsub!(/application_url:.*$/, "application_url: #{application_url}")
      File.open(config_working_directory_path, 'w') { |f| f.write(configuration) }
    end

    LOG.info "done! You should take a look an edit it to your needs..."
  end

  private
  def base_config_path
    File.join(File.dirname(__FILE__), '..', '..', 'config')
  end

end