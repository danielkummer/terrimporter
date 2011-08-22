require 'etc'
require 'kwalify'
require 'config_validator'

module TerrImporter
  class Application
    class Configuration < Hash

      CONFIG_DEFAULT_NAME = 'terrimporter.config.yml'
      SCHEMA_DEFAULT_NAME = 'schema.yml'

      attr_accessor :validations, :config_file

      def initialize(config_file = nil)
        self.config_file = config_file unless config_file.nil?

      end

      def load_configuration
        config_file_path = determine_config_file_path
        validate_and_load_config(config_file_path)
      end

      def determine_config_file_path
        unless self.config_file.nil?
          return self.config_file
        end

        valid_config_paths.each do |path|
          file_path = File.join path, CONFIG_DEFAULT_NAME
          return file_path if File.exists?(file_path)
        end

        raise ConfigurationError, %Q{config file #{CONFIG_DEFAULT_NAME} not found in search paths. Search paths are:
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
        puts "Load configuration "

        schema = Kwalify::Yaml.load_file(schema_file_path)
        #validator = Kwalify::Validator.new(schema)
        validator = ConfigValidator.new(schema)

        parser = Kwalify::Yaml::Parser.new(validator)
        document = parser.parse_file(file)
        ## show errors if exist
        errors = parser.errors()
        ##todo convert to single statement, map for example
        if errors && !errors.empty?
          error_message = ""
          for e in errors
            error_message << "#{e.linenum}:#{e.column} [#{e.path}] #{e.message}\n"
          end
          raise ConfigurationError, error_message
        end

        self.merge! document

      end

      def schema_file_path
        File.join(File.dirname(__FILE__), '..', 'config', SCHEMA_DEFAULT_NAME)
      end

      #todo
      def validate_schema
        meta_validator = Kwalify::MetaValidator.instance

        ## validate schema definition
        parser = Kwalify::Yaml::Parser.new(meta_validator)
        errors = parser.parse_file(schema_file_path)
        for e in errors
          puts "#{e.linenum}:#{e.column} [#{e.path}] #{e.message}"
        end if errors && !errors.empty?
      end

      def create_config
        FileUtils.cp(File.join(File.dirname(__FILE__), "..", "config", CONFIG_DEFAULT_NAME), File.join(Dir.pwd, CONFIG_DEFAULT_NAME))
      end
    end
  end
end