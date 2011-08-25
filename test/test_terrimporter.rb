require 'test_helper'

class TestTerrimporter < Test::Unit::TestCase
  include ConfigHelper

  def setup
    ENV['TERRIMPORTER_OPTS'] = nil
  end

  def teardown
    File.delete config_file if File.exists? config_file
  end

  should 'build options as a combination form argument options and environment options' do
    ENV['TERRIMPORTER_OPTS'] = "-j"
    arguments = ["testfile", '-c']
    merged_options = TerrImporter::Application.build_options(arguments)
    assert merged_options.include?(:import_js)
    assert merged_options.include?(:import_css)
  end

  should 'run the importer with the init command and a non existing configuration file' do
    TerrImporter::Application.run!(["test"], ['--init'])
    assert File.exists? config_file
  end

  def config_file
    File.join(File.dirname(__FILE__), '..', config_default_name)
  end


end
