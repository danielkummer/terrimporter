module TerrImporter

  class DefaultError < StandardError
  end

  class ConfigurationError < StandardError
  end

  class ConfigurationMissingError < StandardError
  end

  class Application
    class Importer
      include Logging

      attr_accessor :options, :config

      def initialize(options = {})
        self.options = options
        self.config = Configuration.new options[:config_file]
        self.config.load_configuration
        @downloader = Downloader.new config['application_url']
      end

      def run


        if options[:all] != nil and options[:all] == true
          puts "Import of everything started"
          import_js
          import_css
          import_images
        else
          options.each do |option, value|
            if option.to_s =~ /^import_/ and value == true
              puts "Import of #{option.to_s.split('_').last} started"
              self.send option.to_s
            end
          end
        end
      end

      def determine_configuration_values_from_uri
        result = @downloader.download('')
        result =~ /\/terrific\/base\/(.*?)\/public\/.*application=(.*?)(&amp;|&)/

        terrific_version = $1
        app_path = $2

        raise ConfigurationError, "Unable to determine necessary configuration value #{terrific_version} from application url" if terrific_version.nil?
        raise ConfigurationError, "Unable to determine necessary configuration value #{app_path} from application url" if app_path.nil?

        puts "Determined the following configuration values from #{config['application_url']}:\n" +
                 "terrific version: #{terrific_version} \n" +
                 "application path: #{app_path}"

        config['version'] = terrific_version
        config['app_path'] = app_path
      end

      def import_css
        check_and_complete_config!
        unclean_suffix = "_unclean"

        check_and_create_dir config['stylesheets']['relative_destination_path']

        #create stylesheet array and add base.css
        styles = config['stylesheets']['styles'].split(" ")
        styles << "base"

        styles.each do |css|
          relative_destination_path = File.join(config['stylesheets']['relative_destination_path'], css + ".css")
          options = {}
          options[:suffix] = css if css.include?('ie') #add ie option if in array

          source_url = construct_export_path(:css, options)

          @downloader.download(source_url, relative_destination_path + unclean_suffix)

          #do line replacement
          puts "Start css line replacements"
          File.open(relative_destination_path, 'w') do |d|
            File.open(relative_destination_path + unclean_suffix, 'r') do |s|
              lines = s.readlines
              lines.each do |line|
                d.print stylesheet_replace_strings!(line)
              end
            end
          end
          puts "Deleting unclean css files"
          FileUtils.remove relative_destination_path + unclean_suffix
        end
      end

      def import_js
        check_and_complete_config!
        check_and_create_dir config['javascripts']['relative_destination_path']
        relative_destination_path = File.join(config['javascripts']['relative_destination_path'], "base.js")
        js_source_url = construct_export_path :js

        puts "Importing base.js from #{js_source_url} to #{relative_destination_path}"

        @downloader.download(js_source_url, relative_destination_path)

        if config['javascripts']
          not nil
          libraries_relative_destination_path = File.join(config['javascripts']['relative_destination_path'], config['javascripts']['relative_libraries_destination_path'])
          check_and_create_dir libraries_relative_destination_path
          js_libraries = config['javascripts']['dynamic_libraries'].split(" ")

          puts "Importing libraries from #{config['libraries_server_path']} to #{libraries_relative_destination_path}"

          if config['libraries_server_path'].nil?
            puts "Please define 'libraries_server_path' in configuration file"
          else
            js_libraries.each do |lib|
              @downloader.download(File.join(config['libraries_server_path'], lib+ ".js"), File.join(libraries_relative_destination_path, lib + ".js"))
            end

          end

        end

      end

      def import_images
        check_and_complete_config!
        config['images'].each do |image|
          check_and_create_dir image['relative_destination_path']
          image_source_path = File.join(config['image_server_path'], image['server_path'])
          batch_download(image_source_path, image['relative_destination_path'], image['file_types'])
        end
      end

      private

      def batch_download(relative_source_path, relative_dest_path, type_filter = "")
        source_path = relative_source_path

        puts "Downloading multiple files from #{config['application_url']}#{source_path} to #{relative_dest_path} #{"allowed extensions: " + type_filter unless type_filter.empty?}"

        files = html_directory_content_list(source_path)

        unless type_filter.empty?
          puts "Appling type filter: #{type_filter}"
          files = files.find_all { |file| file =~ Regexp.new(".*" + type_filter.strip.gsub(" ", "|") + "$") }
        end

        puts "Downloading #{files.size} files..."
        files.each do |file|
          relative_destination_path = File.join(relative_dest_path, file)
          @downloader.download(File.join(source_path, file), relative_destination_path)
        end
      end

      def html_directory_content_list(source_path)
        puts "Getting html directory list"
        output = @downloader.download(source_path)
        files = []

        output.scan(/<a\shref=\"([^\"]+)\"/) do |res|
          files << res[0] if not res[0] =~ /^\?/ and not res[0] =~ /.*\/$/ and res[0].size > 1
        end
        puts "Found #{files.size} files"
        files
      end

      def construct_export_path(for_what = :js, options={})
        raise DefaultError, "Specify js or css url" unless for_what == :js or for_what == :css
        export_settings = config['export_settings'].clone

        export_settings['application'] = config['app_path']
        export_settings.merge!(options)
        export_settings['appbaseurl'] = "" if for_what == :css

        #glue everything together
        export_path = config['export_path']
        export_path.insert(0, "/") unless export_path.match(/^\//)

        export_path = export_path % [for_what.to_s, config['version']] #replace placeholders
        export_path << '?' << export_settings.map { |k, v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join("&")
        export_path
      end

      def check_and_create_dir(dir, create = true)
        created_or_exists = false
        unless File.directory?(dir)
          puts "Directory #{dir} does not exists... it will #{"not" unless create} be created"
          if create
            FileUtils.mkpath(dir)
            created_or_exists = true
          end
        else
          created_or_exists = true
        end
        created_or_exists
      end

      def stylesheet_replace_strings!(line)
        config['stylesheets']['replace_strings'].each do |replace|
          what = replace['what']
          with = replace['with']
          what = Regexp.new "#{$1}" if what.match(/^r\/(.*)\//)

          puts "Replacing #{what.to_s} with #{with}"

          line.gsub! what, with
        end
        line
      end

      def check_and_complete_config!
        unless config.required_present?
          determine_configuration_values_from_uri
        end
      end
    end
  end
end
