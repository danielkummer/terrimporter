require 'etc'
require 'kwalify'
require 'config_validator'
require 'config_helper'
require 'configuration'

module TerrImporter
  class Application
    class Configuration < Hash
      include ConfigHelper

      attr_accessor :validations, :config_file

      def initialize(config_file = nil)
        self.config_file = config_file unless config_file.nil?

      end

      def load_configuration
        config_file_path = determine_config_file_path
        puts "Configuration file located, load from #{config_file_path}"
        validate_and_load_config(config_file_path)
      end

      def determine_config_file_path
        unless self.config_file.nil?
          return self.config_file
        end

        valid_config_paths.each do |path|
          file_path = File.join path, config_default_name
          return file_path if File.exists?(file_path)
        end

        raise ConfigurationError, %Q{config file #{config_default_name} not found in search paths. Search paths are:
        #{valid_config_paths.join "\n"} \n If this is a new project, run with the option --init}
      end

      def valid_config_paths
        [
            Dir.pwd,
            File.join(Dir.pwd, 'config'),
            File.join(Dir.pwd, '.config'),
            Etc.getpwuid.dir
        ]
      end

      #todo split!
      def validate_and_load_config(file)
        puts "Validating configuration..."

        parser = Kwalify::Yaml::Parser.new(load_validator)
        document = parser.parse_file(file)

        errors = parser.errors()
        if errors && !errors.empty?
          errors.inject("") { |result, e| result << "#{e.linenum}:#{e.column} [#{e.path}] #{e.message}\n" }
          raise ConfigurationError, error_message
        end
        self.merge! document

      end

      def load_validator
        puts "Loading validator from #{schema_file_path}"
        schema = Kwalify::Yaml.load_file(schema_file_path)
        ConfigValidator.new(schema)
      end

    end
  end
end