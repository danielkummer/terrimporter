require 'shellwords'
require 'options'
require 'importer'


class TerrImporter
  class Application
    class << self
      include Shellwords

      def run!(*arguments)
        options = build_options(arguments)

        if options[:invalid_argument]
          $stderr.puts options[:invalid_argument]
          options[:show_help] = true
        end

        if options[:show_help]
          $stderr.puts options.opts
          return 1
        end

        if options[:input_file].nil?
          $stderr.puts options.opts
          return 1
        end

        begin

          #todo crete config file in current working directory first
          create_config unless File.exists?(File.join(Dir.pwd, CONFIG_DEFAULT_NAME))

          importer = TerrImporter::Importer.new(options)
          importer.run
          return 0
        rescue Importer::DefaultError
          $stderr.puts %Q{Unspecified Error #{ $!.message }}
          return 1

        end
      end

      def create_config
        FileUtils.cp(File.join(__FILE__, "../", "config", CONFIG_DEFAULT_NAME), File.join(Dir.pwd, CONFIG_DEFAULT_NAME))
      end


      def build_options(arguments)
        env_opts_string = ENV['CSV2MOD_REWRITE_OPTS'] || ""
        env_opts = TerrImporter::Application::Options.new(shellwords(env_opts_string))
        argument_opts = TerrImporter::Application::Options.new(arguments)
        env_opts.merge(argument_opts)
      end
    end
  end
end

