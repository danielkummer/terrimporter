require "helper"
require "FileUtils"


class TerrImporterTest < Test::Unit::TestCase

  def teardown
    FileUtils.rm_rf File.join(Dir.pwd, TerrImporter::CONFIG_DEFAULT_NAME)
  end

  should 'merge environment and argument options' do
    ENV['TERRIMPORTER_OPTS'] = '-j -c'
    merged_options = TerrImporter::Application.build_options([''] + ['-i', '--verbose'])
    expected_options = {:import_css => true,
                        :import_js => true,
                        :import_images => true,
                        :verbose => true,
                        :input_file => ''}

    assert_contains merged_options, expected_options
  end

  should 'create a config file in the current directory' do
    TerrImporter::Application.create_config
    assert File.exists?(File.join(Dir.pwd, TerrImporter::CONFIG_DEFAULT_NAME))
  end
end