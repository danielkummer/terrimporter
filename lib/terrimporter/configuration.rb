#require 'etc'
#require 'kwalify'

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
          return file_path if File.exists?(file_path) and not file_path.include?(File.join('terrimporter', 'config')) #default config NOT valid
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
          error_message = errors.inject("") { |result, e| result << "#{e.linenum}:#{e.column} [#{e.path}] #{e.message}\n" }
          raise ConfigurationError, error_message
        end
        self.merge! document

      end

      def load_validator
        puts "Loading validator from #{schema_file_path}"
        schema = Kwalify::Yaml.load_file(schema_file_path)
        Kwalify::Validator.new(schema)
      end

      def required_present?
        if self['export_path'].nil? or self['export_settings']['application'].nil? or self['application_url'].nil?
          false
        else
          true
        end
      end

      #todo test from here on out
      def stylesheets
        stylesheets = ["base.css"]
        if additional_stylesheets?
          stylesheets = stylesheets + robust_split(self['stylesheets']['styles'])
        else
          puts "No additional stylesheets defined."
        end
        correct_extension!(stylesheets, '.css')
      end

      def dynamic_libraries
        libraries = robust_split(self['javascripts']['dynamic_libraries'])
        correct_extension!(libraries, '.js')
      end

      def replace_style_strings?
        !self['stylesheets'].nil? and !self['stylesheets']['replace_strings'].nil?
      end

      def additional_dynamic_javascripts?
        !self['javascripts'].nil? and !self['javascripts']['dynamic_libraries'].nil?
      end

      def libraries_destination_path
        if !self['javascripts']['libraries_relative_destination_path'].nil?
          File.join(self['javascripts']['libraries_relative_destination_path'])
        else
          File.join(self['javascripts']['relative_destination_path'])
        end
      end

      def images?
        !self['images'].nil?
      end

      #todo move to helper method
      def robust_split(string) #todo test
        case string
          when /,/
            string.split(/,/).collect(&:strip)
          when /\s/
            string.split(/\s/).collect(&:strip)
          else
            [string.strip]
        end
      end


      def additional_stylesheets? #todo test
        !self['stylesheets'].nil? and !self['stylesheets']['styles'].nil?
      end


      #todo move to helper method or even extend array class
      def correct_extension!(array, extension) #todo test
        array.collect! do |item|
          unless item =~ /#{extension}$/
            item + extension
          else
            item
          end
        end

      end

    end
  end
end