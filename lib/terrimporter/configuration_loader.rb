module TerrImporter
  class Application
    class ConfigurationLoader

      attr_accessor :config_file

      def initialize(config_file = nil)
        self.config_file = config_file unless config_file.nil?
      end

      #todo also complete missing values here, after this step everything should work...
      def load_configuration
        config_file_path = determine_config_file_path
        LOG.debug "Configuration file located, load from #{config_file_path}"
        c = validate_and_load_config(config_file_path)
        c['version'], c['export_settings']['application'], c['css_export_path'], c['js_export_path'] = determine_configuration_values_from_html(Downloader.new(c['application_url']).download(''))
        c
      end

      def determine_config_file_path
        return self.config_file unless self.config_file.nil?

        config_search_paths.each do |path|
          file_path = File.join(path, config_default_name)
          #default config supplied with terrimporter NOT valid
          return file_path if File.exists?(file_path) and not file_path.include?(File.join('terrimporter', 'config'))
        end

        raise ConfigurationError, %Q{Configuration file #{config_default_name} not found in search paths. Search paths are:
        #{config_search_paths.join "\n"} \n If this is a new project, run with the option --init}
      end

      def validate_and_load_config(file)
        LOG.debug "Validate configuration file"
        parser = Kwalify::Yaml::Parser.new(load_validator)
        document = parser.parse_file(file)
        errors = parser.errors()

        if errors && !errors.empty?
          error_message = errors.inject("") { |result, e| result << "#{e.linenum}:#{e.column} [#{e.path}] #{e.message}\n" }
          raise ConfigurationError, error_message
        end
        document
      end

      def load_validator
        LOG.debug "Loading configuration file validator from #{schema_file_path}"
        schema = Kwalify::Yaml.load_file(schema_file_path)
        Kwalify::Validator.new(schema)
      end

      def determine_configuration_values_from_html(raw_html)
        css_result, js_result = raw_html.scan(/(\/terrific\/base\/(.*?)\/public\/.*base.(css|js).php)\?.*application=(.*?)(&amp;|&)/)

        raise ConfigurationError, "Unable to extract css information from application url, content is: #{raw_html}" if css_result.nil? or css_result.size < 5
        raise ConfigurationError, "Unable to extract javascript information from application url, content is: #{raw_html}" if js_result.nil? or js_result.size < 5

        css_export_path = css_result[0]
        js_export_path = js_result[0]
        terrific_version = css_result[1]
        application = css_result[3]

        raise ConfigurationError, "Unable to determine css export path" if css_export_path.nil?
        raise ConfigurationError, "Unable to determine js export path " if js_export_path.nil?
        raise ConfigurationError, "Unable to determine terrific version" if terrific_version.nil?
        raise ConfigurationError, "Unable to determine application path" if application.nil?

        LOG.info "Determined the following configuration values from #{self['application_url']}:\n" +
                     "terrific version: #{terrific_version} \n" +
                     "application path: #{application}"

        #self['version'] = terrific_version
        #self['export_settings'] ||= {}
        #self['export_settings']['application'] = application
        #self['css_export_path'] = css_export_path
        #self['js_export_path'] = js_export_path
        [terrific_version, application, css_export_path, js_export_path]
      end

      def config_default_name
        'terrimporter.yml'
      end

      def schema_default_name
        'schema.yml'
      end

      def config_search_paths
        [
            Dir.pwd,
            File.join(Dir.pwd, 'config'),
            File.join(Dir.pwd, '.config'),
        ]
      end

      def config_working_directory_path
        File.expand_path config_default_name
      end

      def config_working_directory_exists?
        File.exists? config_working_directory_path
      end

      def config_example_path
        File.join(base_config_path, config_default_name)
      end

      def schema_file_path
        File.join(base_config_path, schema_default_name)
      end

      def base_config_path
        File.join(File.dirname(__FILE__), '..', '..', 'config')
      end
    end
  end
end
