module TerrImporter
  class Application
    #todo split importer into css_importer, image_importer, module_importer, js_importer
    class Importer
      include ImporterHelper
      attr_accessor :options, :config

      def initialize(options = {})
        self.options = options
        loader = ConfigurationLoader.new(options[:config_file])
        self.config = loader.load_configuration
        initialize_downloader
      end

      def initialize_downloader
        @downloader = Downloader.new(config.application_url)
      end

      def run
        if options[:all] != nil and options[:all] == true
          run_all_imports
        else
          run_specific_imports
        end
      end

      def run_all_imports
        LOG.info "Import everything"
        import_js
        import_css
        import_images
        import_modules
      end

      def run_specific_imports
        options.each do |option, value|
          if option.to_s =~ /^import_/ and value == true
            LOG.info "Import of #{option.to_s.split('_').last} started"
            self.send option.to_s
          end
        end
      end

      def import_css
        LOG.info("Importing stylesheets")

        unclean_suffix = "_unclean"
        stylesheets = config.list_stylesheets

        stylesheets.each do |css|
          file_path = File.join(config.stylesheets_target_dir, css)
          options = {}
          options[:suffix] = $1 if css =~ /(ie.*).css$/ #add ie option if in array
          source_url = export_path(:css, options)
          unclean_file_path = file_path + unclean_suffix;
          constructed_file_path = (config.replace_style_strings? ? unclean_file_path : file_path)

          begin

            @downloader.download(source_url, constructed_file_path)
            STAT.add(:css)

            #todo move to method
            if file_contains_valid_css?(constructed_file_path)
              if config.replace_style_strings?
                LOG.info "CSS line replacements"
                File.open(file_path, 'w') do |d|
                  File.open(constructed_file_path, 'r') do |s|
                    lines = s.readlines
                    lines.each do |line|
                      d.print replace_stylesheet_lines!(line)
                    end
                  end
                end
              else
                LOG.debug "Skipping css line replacements"
              end

              if File.exists?(unclean_file_path)
                LOG.debug "Deleting unclean css files"
                FileUtils.remove unclean_file_path
              end
            else
              FileUtils.remove(file_path)
              LOG.debug "Deleting empty"
            end
          rescue DownloadError => e
            LOG.error(e)
          end
        end
      end

      def import_js
        LOG.info("Importing javascripts")
        file_path = File.join(config.javascripts_target_dir, "base.js")
        js_source_url = export_path(:js)
        LOG.debug "Import base.js from #{js_source_url} to #{file_path}"
        @downloader.download(js_source_url, file_path)
        STAT.add(:js)
        if config.has_libraries?
          if config.libraries_server_dir.nil?
            LOG.info "Define 'libraries_server_dir' in configuration file"
          else
            libraries_file_path = config.libraries_target_dir
            LOG.info "Import libraries from #{config.libraries_server_dir} to #{libraries_file_path}"
            js_libraries = config.list_libraries
            js_libraries.each do |lib|
              begin
                @downloader.download(File.join(config.libraries_server_dir, lib), File.join(libraries_file_path, lib))
                STAT.add(:js)
              rescue DownloadError => e
                LOG.error(e)
              end
            end
          end
        end

        if config.has_plugins?
          unless config.has_plugins_server_dir?
            LOG.info "Define 'plugins_server_dir' in configuration file"
          else
            plugins_file_path = config.plugins_target_dir
            LOG.info "Import plugins from #{config.plugins_server_dir} to #{plugins_file_path}"
            js_plugins = config.list_plugins
            js_plugins.each do |lib|
              begin
                @downloader.download(File.join(config.plugins_server_dir, lib), File.join(plugins_file_path, lib))
                STAT.add(:js)
              rescue DownloadError => e
                LOG.error(e)
              end
            end
          end
        end
      end

      def import_images
        if config.has_images?
          LOG.info "Import images"
          config.images.each do |image|
            image_source_path = File.join(config.images_server_dir, image['server_dir'])
            @downloader.batch_download(image_source_path, image['target_dir'], image['file_types'], :image)
          end
        else
          LOG.debug "Skipping image import"
        end
      end

      def import_modules

        if config.has_modules?
          LOG.info "Module import"
          config.modules.each do |mod|
            name = mod['name']
            skin = mod['skin']
            module_source_url = module_path(name, mod['module_template'], skin, mod['template_only'])
            filename = name.clone
            filename << "_#{skin}" unless skin.to_s.strip.length == 0
            begin
              @downloader.download(module_source_url, File.join(mod['target_dir'], filename + '.html'))
              STAT.add(:module)
            rescue DownloadError => e
              LOG.error(e)
            end
          end
        else
          LOG.debug "Skipping module import"
        end
      end

      def module_path(name, module_template, skin = nil, template = nil)
        skin = '' if skin.nil?
        raise ConfigurationError, "Name cannot be empty for template" if name.nil?
        raise ConfigurationError, "Module template missing in configuration for template #{name}" if module_template.nil?
        export_path = config.application_url.clone
        export_path << "/terrific/module/details/#{name}/#{module_template}/#{skin}/format/module#{"content" if template}"
        export_path
      end

      private

      def export_path(for_what = :js, options={})
        raise DefaultError, "Specify js or css url" unless for_what == :js or for_what == :css
        export_settings = config.export_settings.clone
        export_settings.merge!(options)
        export_settings['appbaseurl'] = "" if for_what == :css

        export_path = (for_what == :js) ? config.js_export_path.clone : config.css_export_path.clone
        export_path << '?' << export_settings.map { |k, v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join("&")
        export_path
      end

      def replace_stylesheet_lines!(line)
        config.stylesheets_replace.each do |replace|
          replace_line!(line, replace['what'], replace['with'])
        end
        line
      end
    end
  end
end
