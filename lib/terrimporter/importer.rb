module TerrImporter

  class DefaultError < StandardError
  end

  class ConfigurationError < StandardError
  end

  class ConfigurationMissingError < StandardError
  end

  class Application
    #todo split importer -> subclass from baseimporter into specified css, img, js and module importer classes
    class Importer

      attr_accessor :options, :config

      def initialize(options = {})
        self.options = options
        self.config = Configuration.new options[:config_file]
        self.config.load_configuration
        @downloader = Downloader.new config['application_url']
      end

      def run


        if options[:all] != nil and options[:all] == true
          LOG.info "Import everything"
          import_js
          import_css
          import_images
          import_modules
        else
          options.each do |option, value|
            if option.to_s =~ /^import_/ and value == true
              LOG.info "Import of #{option.to_s.split('_').last} started"
              self.send option.to_s
            end
          end
        end
      end

      #todo at the wrong place, move to configuration
      def determine_configuration_values_from_uri
        result = @downloader.download('')
        #result =~ /\/terrific\/base\/(.*?)\/public\/.*application=(.*?)(&amp;|&)/
        #result =~ /(\/terrific\/base\/(.*?)\/public\/.*base.(css|js).php).*application=(.*?)(&amp;|&)/

        css_result, js_result = result.scan(/(\/terrific\/base\/(.*?)\/public\/.*base.(css|js).php)\?.*application=(.*?)(&amp;|&)/)


        if css_result.nil? or css_result.size < 5
          raise ConfigurationError, "Unable to extract css information from application url, content is: #{result}"
        end
        if js_result.nil? or js_result.size < 5
          raise ConfigurationError, "Unable to extract javascript information from application url, content is: #{result}"
        end

        css_export_path = css_result[0]
        js_export_path = js_result[0]
        terrific_version = css_result[1]
        application = css_result[3]

        raise ConfigurationError, "Unable to determine css export path from application url" if css_export_path.nil?
        raise ConfigurationError, "Unable to determine js export path from application url" if js_export_path.nil?

        LOG.info "Determined the following configuration values from #{config['application_url']}:\n" +
                     "terrific version: #{terrific_version} \n" +
                     "application path: #{application}"

        config['version'] = terrific_version
        config['export_settings']['application'] = application
        config['export_path'] = {'css' => css_export_path, 'js' => js_export_path}
      end

      def import_css
        check_and_complete_config!
        unclean_suffix = "_unclean"

        check_and_create_dir config['stylesheets']['relative_destination_path']

        styles = config.stylesheets

        styles.each do |css|
          relative_destination_path = File.join(config['stylesheets']['relative_destination_path'], css)
          options = {}
          options[:suffix] = $1 if css =~ /(ie.*).css$/ #add ie option if in array

          source_url = construct_export_path(:css, options)

          @downloader.download(source_url, relative_destination_path + unclean_suffix)

          if config.replace_style_strings?
            LOG.info "CSS line replacements"
            File.open(relative_destination_path, 'w') do |d|
              File.open(relative_destination_path + unclean_suffix, 'r') do |s|
                lines = s.readlines
                lines.each do |line|
                  d.print stylesheet_replace_strings!(line)
                end
              end
            end
          else
            LOG.info "Skipping css line replacements"
          end
          LOG.info "Deleting unclean css files"
          FileUtils.remove relative_destination_path + unclean_suffix
        end
      end

      def import_js
        check_and_complete_config!
        check_and_create_dir config['javascripts']['relative_destination_path']
        relative_destination_path = File.join(config['javascripts']['relative_destination_path'], "base.js")
        js_source_url = construct_export_path :js

        LOG.info "Import base.js from #{js_source_url} to #{relative_destination_path}"

        @downloader.download(js_source_url, relative_destination_path)


        if config.additional_dynamic_javascripts?

          libraries_destination_path = config.libraries_destination_path
          check_and_create_dir libraries_destination_path
          js_libraries = config.dynamic_libraries

          LOG.info "Import libraries from #{config['libraries_server_path']} to #{libraries_destination_path}"

          if config['libraries_server_path'].nil?
            LOG.info "Define 'libraries_server_path' in configuration file"
          else
            js_libraries.each do |lib|
              @downloader.download(File.join(config['libraries_server_path'], lib), File.join(libraries_destination_path, lib))
            end

          end

        end
      end

      def import_images
        check_and_complete_config!
        if config.images?
          LOG.info "Import images"

          config['images'].each do |image|
            check_and_create_dir image['relative_destination_path']
            image_source_path = File.join(config['image_server_path'], image['server_path'])
            @downloader.batch_download(image_source_path, image['relative_destination_path'], image['file_types'])
          end
        else
          LOG.info "Skipping image import"
        end
      end

      def import_modules

        if config.modules?
          LOG.info "Module import"

          config['modules'].each do |mod|
            check_and_create_dir mod['relative_destination_path']
            #todo download module to
            module_source_url = construct_module_path(mod['name'], mod['module_template'], mod['skin'], mod['template_only'])
            @downloader.download(module_source_url, File.join(mod['relative_destination_path'], mod['name'] + '.html'))
          end
        end
      end

      def construct_module_path(name, module_template, skin = nil, template = nil)
        skin = '' if skin.nil?
        #todo add not empty check to name and module_template -> most probably in configuration file
        # todo complete!
        #todo refactor export path to be more universal
        export_path = config['application_url'].clone
        #todo moduletemplate missing!
        export_path << "/terrific/module/details/#{name}/#{module_template}/#{skin}/format/module#{"content" if template}"
        export_path
      end

      private

      def construct_export_path(for_what = :js, options={})
        raise DefaultError, "Specify js or css url" unless for_what == :js or for_what == :css
        export_settings = config['export_settings'].clone

        export_settings.merge!(options)
        export_settings['appbaseurl'] = "" if for_what == :css

        export_path = config['export_path'][for_what.to_s].clone
        export_path << '?' << export_settings.map { |k, v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join("&")
        export_path
      end

      def check_and_create_dir(dir, create = true)
        created_or_exists = false
        unless File.directory?(dir)
          LOG.info "Directory #{dir} does not exists... it will #{"not" unless create} be created"
          if create
            FileUtils.mkpath(dir)
            created_or_exists = true
          end
        else
          created_or_exists = true
        end
        created_or_exists
      end

      #todo refactor config access away
      def stylesheet_replace_strings!(line)
        config['stylesheets']['replace_strings'].each do |replace|
          what = replace['what']
          with = replace['with']
          what = Regexp.new "#{$1}" if what.match(/^r\/(.*)\//)

          LOG.info "Replacing #{what.to_s} with #{with}"

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
