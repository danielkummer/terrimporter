require 'fileutils'
require 'app_logger'
require 'yaml'
require 'uri'


class TerrImporter

  CONFIG_DEFAULT_NAME = 'terrimporter.config.yml'

  class DefaultError < StandardError
  end

  class Importer
    require 'options'
    include Logging

    attr_accessor :options, :config

    def initialize(options = {})
      self.options = options
      file = File.join(Dir.pwd, CONFIG_DEFAULT_NAME)
      if config_exists?(file)
        init_config(file)
      else
        raise "no configuration found, exiting..."
      end
    end

    def run
      if options[:all] != nil and options[:all] == true
        import_js
        import_css
        import_images
      else
        options[:import].each do |import|
          #test this really good!!!
          Importer.send("import_" + import.to_s)
        end
      end
    end

    def import_css
      unclean_suffix = "_unclean"

      check_and_create_dir config['stylesheets']['dest']

      #create stylesheet array and add base.css
      styles = config['stylesheets']['styles'].split(" ")
      styles << "base"

      styles.each do |css|
        destination_path = File.join(config['stylesheets']['dest'], css + ".css")
        options = {}
        options[:suffix] = css if css.include?('ie') #add ie option if in array

        source_url = construct_export_request(:css, options)
        run_download(source_url, destination_path + unclean_suffix)

        #do line replacement
        File.open(destination_path, 'w') do |d|
          File.open(destination_path + unclean_suffix, 'r') do |s|
            lines = s.readlines
            lines.each do |line|
              d.print stylesheet_replace_strings(line)
            end
          end
        end
        FileUtils.remove destination_path + unclean_suffix
      end
    end

    def import_js
      destination_path = File.join(config['javascripts']['dest'], "base.js")
      js_source_url = construct_export_request :js
      puts "Importing base.js from #{js_source_url} to #{destination_path}"
      run_download(js_source_url, destination_path)

      #start library import

      libraries_destination_path = File.join(config['javascripts']['dest'], config['javascripts']['libraries_dest'])

      check_and_create_dir libraries_destination_path

      js_libraries = config['javascripts']['dynamic_libraries'].split(" ")

      puts "Importing libraries from #{config['libraries_source_path']} to #{libraries_destination_path}"

      js_libraries.each do |lib|
        run_download(config['libraries_source_path'] + lib + ".js", File.join(libraries_destination_path, lib + ".js"))
      end

    end

    def import_images
      config['images'].each do |image|
        check_and_create_dir image['dest']
        image_source_path = File.join(config['image_base_path'], image['src'])
        batch_download_files(image_source_path, image['dest'], image['types'])
      end
    end

    private

    def config_exists?(config)
      raise "config file #{config} doesn't exist, if this is a new project, run with the option -i'" unless File.exists?(config)
    end

    def validate_config(config)
      raise "specify downloader (curl or wget)" unless config['downloader'] =~ /curl|wget/
      raise "url format invalid" unless config['url'] =~ URI::regexp
      raise "version invalid" if config['version'].to_s.empty?
      raise "app path invalid" if config['app_path'].to_s.empty?
      raise "export path invalid" if config['export_path'].to_s.empty?
      raise "image base path invalid" if config['image_base_path'].to_s.empty?
      config['stylesheets']['styles'].each do |css|
        raise ".css extension not allowed on style definition: #{css}" if css =~ /\.css$/
      end
      config['javascripts']['dynamic_libraries'].each do |js|
        raise ".js extension not allowed on javascript dynamic library definition: #{js}" if js =~ /\.js$/
      end
      raise "dynamic javascript libraries path invalid" if config['javascripts']['libraries_dest'].to_s.empty?
    end

    def init_config(file)
      puts "Load configuration "
      config = YAML.load_file(file)['terrific']
      validate_config config
    end


    def batch_download_files(relative_source_path, relative_dest_path, type_filter = "")
      source_path = relative_source_path

      puts "Downloading files from #{config['url']}#{source_path} to #{relative_dest_path} #{"allowed extensions: " + type_filter unless type_filter.empty?}"

      files = get_file_list(source_path)

      unless type_filter.empty?
        puts "Appling type filter: #{type_filter}"
        files = files.find_all { |file| file =~ Regexp.new(".*" + type_filter.strip.gsub(" ", "|") + "$") }
      end

      puts "Downloading #{files.size} files..."
      files.each do |file|
        destination_path = File.join(relative_dest_path, file)
        run_download(source_path + file, destination_path, :remove_old => false)
      end
    end

    def get_file_list(source_path)
      output = run_download(source_path)
      files = []

      output.scan(/<a\shref=\"([^\"]+)\"/) { |res| files << res[0] if not res[0] =~ /^\?/ and res[0].size > 1 }
      files
    end

    def construct_export_request(for_what = :js, options={})
      raise "Specify js or css url" unless for_what == :js or for_what == :css
      export_settings = config['export_settings'].clone

      export_settings['application'] = config['app_path']
      export_settings.merge!(options)
      export_settings['appbaseurl'] = "" if for_what == :css

      #glue everything together
      export_path = config['export_path']
      export_path.insert(0, "/") unless export_path.match(/^\//)

      export_path = export_path % [for_what.to_s, config['version']] #replace placeholders
      export_path << '?' << export_settings.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
      export_path
    end

    def check_and_create_dir(dir, create = true)
      unless File.directory?(dir)
        puts "Directory #{dir} does not exists... it will #{"not" unless true} be created"
        mkdir_p(dir) if create
      end
    end

    def stylesheet_replace_strings(line)
      config['stylesheets']['replace'].each do |replace|
        what = replace['what']
        with = replace['with']
        what = Regexp.new "/#{$1}" if what.match(/^r\//)
        line.gsub! what, with
      end
      line
    end

    #todo use as central download processing
    def run_download(remote_path, local = nil, options = {})
      FileUtils.remove_file(local) if not local.nil? and File.exists?(local) and not File.directory?(local) and not options[:remove_old] == true
      remote_url = config['url'] + remote_path

      case config['downloader']
        when 'curl'
          output = `curl '#{remote_url}' #{"> #{local}" if local != nil}`
          raise "FATAL: An error orrured downloading from #{remote_url} #{"to #{local}: \n #{output}" if local != nil}" if output.include?('error')
          return output
        when 'wget'
          #todo
      end

    end
  end
end
