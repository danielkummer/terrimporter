module TerrImporter
  class Application
    class ConfigurationLoader
      include ConfigurationHelper

      attr_accessor :config_file

      def initialize(config_file = nil)
        self.config_file = config_file unless config_file.nil?
      end

      def load_configuration
        config_file_path = determine_config_file_path
        LOG.debug "Configuration file located, load from #{config_file_path}"
        config_hash = validate_and_load_config(config_file_path)
        config_hash['version'], config_hash['export_settings']['application'], config_hash['css_export_path'], config_hash['js_export_path'] = determine_configuration_values_from_html(Downloader.new(config_hash['application_url']).download(''))
        Configuration.new(config_hash)
      end

      def determine_config_file_path
        #todo this line seems wrong, remove!
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
        #todo this regex does it wrong, it extracts all references and can't decide between js and css. also the version is wrongly extracted if the base path isn't correct
        results = raw_html.scan(/(\/terrific\/base\/(.*?)\/public\/.*base.(css|js).php)\?.*application=(.*?)(&amp;|&)/)
        results.uniq!

        css_result =results.select{|v| v[2] == "css"}.first
        js_result =results.select{|v| v[2] == "js"}.first

        raise ConfigurationError, "Unable to extract configuration information from application url, content is: #{raw_html}" if js_result.nil? or js_result.size < 5

        css_export_path = css_result[0]
        js_export_path = js_result[0]
        terrific_version = css_result[1]     #todo: if it looks like this tags/0.4.0 -> extract number, remove everything before and inclusive /
        application = css_result[3]

        case nil
          when css_export_path
            raise ConfigurationError, "Unable to determine css export path"
          when js_export_path
            raise ConfigurationError, "Unable to determine js export path"
          when terrific_version
            raise ConfigurationError, "Unable to determine terrific version"
          when application
            raise ConfigurationError, "Unable to determine application path"
        end

        LOG.info "Determined the following configuration values:\n" +
                     "terrific version: #{terrific_version} \n" +
                     "application path: #{application}"

        [terrific_version, application, css_export_path, js_export_path]
      end

    end
  end
end
