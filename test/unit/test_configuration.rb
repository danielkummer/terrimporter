require "test_helper"


class ConfigurationTest < Test::Unit::TestCase
  include ConfigurationHelper

  def setup
    FakeWeb.register_uri(:get, "http://terrific.url", :body => File.expand_path('test/fixtures/html/application_root.html'), :content_type => 'text/plain')
    @configuration = TerrImporter::Application::ConfigurationLoader.new(test_config_file_path).load_configuration
  end

  should 'have an image configuration' do
    assert @configuration.has_images?
  end

  should 'have dynamic libraries' do
    assert @configuration.has_dynamic_javascripts?
  end

  should 'have modules' do
    assert @configuration.has_modules?
  end

  should 'use the normal libraries path if no dynamic libraries are specified' do
    @configuration['javascripts']['libraries_destination_path'] = nil
    assert @configuration['javascripts']['destination_path'], @configuration.libraries_destination_path
  end

  should 'have style replacement strings' do
    assert @configuration.replace_style_strings?
  end

  should 'have additional stylesheets configured' do
    assert @configuration.has_stylesheets?
  end

  context 'minimal working configuration' do
    setup do
      @loader = TerrImporter::Application::ConfigurationLoader.new min_test_config_file_path
      @configuration = @loader.load_configuration
    end

    should 'not raise an error when loading the minimal configuration' do
      assert_nothing_raised do
        @loader.load_configuration
      end
    end

    should 'not have an image configuration' do
      assert !@configuration.has_images?
    end

    should 'not have dynamic libraries' do
      assert !@configuration.has_dynamic_javascripts?
    end

    should 'not have style replacement strings' do
      assert !@configuration.replace_style_strings?
    end

    should 'not have additional stylesheets configured' do
      assert !@configuration.has_stylesheets?
    end

    should 'only get the base.css file' do
      assert_equal ["base.css"], @configuration.stylesheets
    end

    should 'not have additional modules' do
      assert !@configuration.has_modules?
    end
  end
end