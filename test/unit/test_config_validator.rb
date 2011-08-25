require "test_helper"


class ConfigValidatorTest < Test::Unit::TestCase
  include ConfigHelper


  should 'collect validation errors on wrongly used configuration file' do
    schema = Kwalify::Yaml.load_file(schema_file_path)
    validator = ConfigValidator.new(schema)

    parser = Kwalify::Yaml::Parser.new(validator)
    document = parser.parse_file(invalid_test_config_file_path)
    errors = parser.errors()
    assert !errors.empty?
    assert errors.size >= 3
  end


end
