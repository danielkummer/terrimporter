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

    should 'merge environment and argument options' do
    ENV['TERRIMPORTER_OPTS'] = '-j -c'
    merged_options = TerrImporter::Application.build_options([''] + ['-i', '--verbose'])
    expected_options = {:import_css => true,
                        :import_js => true,
                        :import_images => true,
                        :show_help => false,
                        :verbose => true}

    assert_contains merged_options, expected_options
  end


  should 'run the importer with the init command and a non existing configuration file' do
    TerrImporter::Application.run!(["test"], '--init')
    assert File.exists? config_file
  end

  should 'run the importer with the init command and a non existing configuration file' do
    TerrImporter::Application.run!(["test"], '--init replace')
    assert File.exists? config_file
  end

  should 'run the importer with the init command and a non existing configuration file' do
    TerrImporter::Application.run!(["test"], '--init','backup')
    assert File.exists? config_file
  end

  should 'run the importer with the init command and an existing configuration file, this leads to an error' do
    TerrImporter::Application.run!(["test"], '--init')
    return_code = TerrImporter::Application.run!(["test"], '--init')
    assert return_code == 1
  end

  should 'run the importer with an invalid argument, display help and return error code' do
    return_code = TerrImporter::Application.run!(["test"], '--invalid')
    assert return_code == 1
  end

  should 'run the importer show help argument, display help and return error code' do
    return_code = TerrImporter::Application.run!(["test"], '--help')
    assert return_code == 1
  end

  should 'run the importer show version and return' do
    return_code = TerrImporter::Application.run!(["test"], '--version')
    assert return_code == 0
  end

  def config_file
    File.join(File.dirname(__FILE__), '..', config_default_name)
  end

end
