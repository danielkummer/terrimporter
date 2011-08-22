require "test/unit"
require "kwalify"

class ConfigurationTest < Test::Unit::TestCase

  def setup
    create_test_configuration_file
    @configuration = TerrImporter::Application::Configuration.new @test_configuration_file
    @configuration.load_configuration
  end

  def teardown
    delete_test_configuration_file
  end

=begin
# somehow the schema validation is not working
  should 'use a valid schema file' do
    meta_validator = Kwalify::MetaValidator.instance
    parser = Kwalify::Yaml::Parser.new(meta_validator)
    errors = parser.parse_file(schema_file_path)

    for e in errors
      #puts "#{e.linenum}:#{e.column} [#{e.path}] #{e.message}"
      puts "#{e.message}"
    end if errors && !errors.empty?

    assert errors.empty?
  end
=end

  should 'find a configuration in the local path' do
    assert_nothing_raised do
      @configuration.determine_config_file_path
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