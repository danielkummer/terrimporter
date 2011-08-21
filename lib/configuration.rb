require 'etc'
require 'kwalify'
require 'config_validator'

module TerrImporter
  class Application
    class Configuration < Hash

      CONFIG_DEFAULT_NAME = 'terrimporter.config.yml'
      SCHEMA_DEFAULT_NAME = 'schema.yml'

      attr_accessor :validations

      def initialize
        config_file = determine_config_file_path
        validate_and_load_config(config_file)
        puts "done"
      end

      def determine_config_file_path
        valid_config_paths.each do |path|
          file_path = File.join path, CONFIG_DEFAULT_NAME
          return file_path if File.exists?(file_path)
        end
        raise ConfigurationError, %Q{config file #{CONFIG_DEFAULT_NAME} not found in search paths. Search paths are:
        #{valid_config_paths.join "\n"} \n If this is a new project, run with the option --init} unless File.exists?(config_file)
      end

      def valid_config_paths
        [
            Dir.pwd,
            File.join(Dir.pwd, 'config'),
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
=begin remove after tested everything
      def validate!
        raise ConfigurationError, "specify downloader (curl or wget)" unless self['downloader'] =~ /curl|wget/
        raise ConfigurationError, "url format invalid" unless self['url'] =~ URI::regexp
        raise ConfigurationError, "version invalid" if self['version'].to_s.empty?
        raise ConfigurationError, "app path invalid" if self['app_path'].to_s.empty?
        raise ConfigurationError, "export path invalid" if self['export_path'].to_s.empty?
        raise ConfigurationError, "image base path invalid" if self['image_base_path'].to_s.empty?
        self['stylesheets']['styles'].each do |css|
          raise ConfigurationError, ".css extension not allowed on style definition: #{css}" if css =~ /\.css$/
        end
        self['javascripts']['dynamic_libraries'].each do |js|
          raise ConfigurationError, ".js extension not allowed on javascript dynamic library definition: #{js}" if js =~ /\.js$/
        end
        raise ConfigurationError, "dynamic javascript libraries path invalid" if self['javascripts']['libraries_dest'].to_s.empty?
      end
=end
    end

  end
end