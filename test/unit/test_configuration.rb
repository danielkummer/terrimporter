require "test/unit"
require "kwalify"

class ConfigurationTest < Test::Unit::TestCase

  def setup
    create_test_configuration_file
    @configuration = TerrImporter::Application::Configuration.new @test_configuration_file
    @configuration.load_configuration
  end

  def teardown
    puts "Cleaning up configuration files"
    delete_test_configuration_file
  end

  should 'find a configuration in the local path and not raise an error' do
    assert_nothing_raised do
      @configuration.determine_config_file_path
    end
  end

  context 'test config file independed functions' do
    setup {
      @configuration = TerrImporter::Application::Configuration.new
    }

    should 'get the current working directory as config file path' do
      config_in_cwd = File.join(Dir.pwd, TerrImporter::Application::Configuration::CONFIG_DEFAULT_NAME)
      assert_equal config_in_cwd, @configuration.determine_config_file_path
    end

    should 'create a config file in the current directory' do
      config_path = File.join(Dir.pwd, TerrImporter::Application::Configuration::CONFIG_DEFAULT_NAME)
      FileUtils.rm_f config_path if File.exists? config_path
      @configuration.create_config
      assert File.exists?(config_path)
    end
  end

  def schema_file_path
    File.join(File.dirname(__FILE__), '..', '..', 'config', TerrImporter::Application::Configuration::SCHEMA_DEFAULT_NAME)
  end

  def create_test_configuration_file
    example_configuration_path = File.join(File.dirname(__FILE__), '..', '..', 'config', TerrImporter::Application::Configuration::CONFIG_DEFAULT_NAME)
    tmp_dir_path = File.join(File.dirname(__FILE__), '..', 'tmp')
    test_configuration_path = File.join(tmp_dir_path, TerrImporter::Application::Configuration::CONFIG_DEFAULT_NAME)
    FileUtils.mkdir(tmp_dir_path) unless File.exist? tmp_dir_path
    FileUtils.cp example_configuration_path, test_configuration_path
    @test_configuration_file = test_configuration_path
  end

  def delete_test_configuration_file
    FileUtils.rm_rf @test_configuration_file if File.exists? @test_configuration_file
  end

end