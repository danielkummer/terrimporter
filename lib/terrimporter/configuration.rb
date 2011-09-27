module TerrImporter
  class Application
    class Configuration < Hash
      include ConfigurationHelper

      attr_accessor :validations, :config_file

      def initialize(config_file = nil)
        self.config_file = config_file unless config_file.nil?
      end

      def load_configuration
        config_file_path = determine_config_file_path
        LOG.debug "Configuration file located, load from #{config_file_path}"
        validate_and_load_config(config_file_path)
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

        self.merge! document
      end

      def load_validator
        LOG.debug "Loading configuration file validator from #{schema_file_path}"
        schema = Kwalify::Yaml.load_file(schema_file_path)
        Kwalify::Validator.new(schema)
      end

      def mandatory_values_present?
        if self['export_path'].nil? or
            self['export_settings']['application'].nil? or
            self['application_url'].nil?
          false
        else
          true
        end
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

        self['version'] = terrific_version
        self['export_settings'] ||= {}
        self['export_settings']['application'] = application
        self['export_path'] = {'css' => css_export_path, 'js' => js_export_path}
      end

      def stylesheets
        stylesheet_list = ["base.css"]
        if has_stylesheets?
          stylesheet_list = stylesheet_list + self['stylesheets']['styles'].to_s.robust_split
        else
          LOG.debug "No additional stylesheets defined in configuration file."
        end
        stylesheet_list.add_missing_extension!('.css')
      end

      def dynamic_libraries
        libraries = self['javascripts']['dynamic_libraries'].robust_split
        libraries.add_missing_extension!('.js')
      end

      def replace_style_strings?
        !self['stylesheets'].nil? and
            !self['stylesheets']['replace_strings'].nil? and
            !self['stylesheets']['replace_strings'].first.nil?
      end

      def libraries_destination_path
        if !self['javascripts']['libraries_destination_path'].nil?
          File.join(self['javascripts']['libraries_destination_path'])
        else
          File.join(self['javascripts']['destination_path'])
        end
      end

      def has_stylesheets?
        !self['stylesheets'].nil? and !self['stylesheets']['styles'].nil?
      end

      def has_dynamic_javascripts?
        !self['javascripts'].nil? and !self['javascripts']['dynamic_libraries'].nil?
      end

      def has_images?
        !self['images'].nil?
      end

      def has_modules?
        !self['modules'].nil?
      end

    end
  end
end