require "test_helper"

require "FileUtils"


class TerrImporterTest < Test::Unit::TestCase
  include ConfigHelper

  def teardown
    FileUtils.rm_rf File.join(Dir.pwd, config_default_name)
  end

  should 'merge environment and argument options' do
    ENV['TERRIMPORTER_OPTS'] = '-j -c'
    merged_options = TerrImporter::Application.build_options([''] + ['-i', '--verbose'])
    expected_options = {:import_css => true,
                        :import_js => true,
                        :import_images => true,
                        :show_help => false,
                        :verbose => true,
                        :input_file => ''}

    assert_contains merged_options, expected_options
  end

end