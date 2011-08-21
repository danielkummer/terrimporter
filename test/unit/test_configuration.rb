require "test/unit"
require "kwalify"

class ConfigurationTest < Test::Unit::TestCase

  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  should 'do some testing' do
    fail 'yeah, implement it baby'
  end

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

  def schema_file_path
    File.join(File.dirname(__FILE__), '..', '..', 'config', TerrImporter::Application::Configuration::SCHEMA_DEFAULT_NAME)
  end

end