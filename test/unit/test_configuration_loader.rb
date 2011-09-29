require "test_helper"


class ConfigurationLoaderTest < Test::Unit::TestCase
  include ConfigurationHelper

  def setup
    FakeWeb.register_uri(:get, "http://terrific.url", :body => File.expand_path('test/fixtures/html/application_root.html'), :content_type => 'text/plain')
    @loader = TerrImporter::Application::ConfigurationLoader.new(test_config_file_path)
  end

  should 'find a configuration in the local path and not raise an error' do
    assert_nothing_raised do
      @loader.determine_config_file_path
    end
  end

  context 'no configuration file around' do
    setup { @loader = TerrImporter::Application::ConfigurationLoader.new }

    should 'not find a configuration in the local path and raise an error' do
      assert_raise TerrImporter::ConfigurationError do
        @loader.load_configuration
        @loader
      end
    end
  end

  context 'invalid config file' do
    setup do
      @loader = TerrImporter::Application::ConfigurationLoader.new invalid_test_config_file_path
    end

    should 'throw an error on an invalid config file' do
      assert_raise TerrImporter::ConfigurationError do
        @loader.load_configuration
      end
    end
  end

  context 'test config file independent functions' do

    #should 'get the current working directory as config file path' do
    #  config_in_cwd = File.join(Dir.pwd, config_default_name)
    #  assert_equal config_in_cwd, @loader.determine_config_file_path
    #end

    should 'create a config file in the current directory' do
      config_path = File.join(Dir.pwd, config_default_name)
      FileUtils.rm_f config_path if File.exists? config_path
      @loader.create_config_file
      assert File.exists?(config_path)
    end
  end

  context 'read additional configuration values from parent page' do

    should 'extract version and app path from parent page' do
      raw_html = File.open(File.expand_path('test/fixtures/html/application_root.html')).read
      assert_nothing_raised do
        version, application, js, css = @loader.determine_configuration_values_from_html raw_html


        assert !version.nil?
        assert !application.nil?
        assert !js.nil?
        assert !css.nil?
      end
    end

    should 'throw a configuration error if the parent pages js values can\'t be read correctly' do
      raw_html = File.open(File.expand_path('test/fixtures/html/application_root_js_error.html')).read
      assert_raises TerrImporter::ConfigurationError do
        @loader.determine_configuration_values_from_html raw_html
      end
    end

    should 'throw a configuration error if the parent pages css values can\'t be read correctly' do
      raw_html = File.open(File.expand_path('test/fixtures/html/application_root_css_error.html')).read
      assert_raises TerrImporter::ConfigurationError do
        @loader.determine_configuration_values_from_html raw_html
      end
    end
  end

end
