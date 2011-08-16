require 'shellwords'
require 'options'
require 'importer'


class TerrImporter
  class Application
    class << self
      include Shellwords

      def run!(*arguments)
        options = build_options(arguments)


        if options[:init]
          create_config unless File.exists?(File.join(Dir.pwd, CONFIG_DEFAULT_NAME))
        end

        if options[:invalid_argument]
          $stderr.puts options[:invalid_argument]
          options[:show_help] = true
        end

        if options[:show_help]
          $stderr.puts options.opts
          return 1
        end

        #if options[:input_file].nil?
        #  $stderr.puts options.opts
        #  return 1
        #end

        begin
          importer = TerrImporter::Importer.new(options)
          importer.run
          return 0
        rescue TerrImporter::ConfigurationError
          $stderr.puts %Q{Configuration Error #{ $!.message }}
        rescue TerrImporter::DefaultError
          $stderr.puts %Q{Unspecified Error #{ $!.message }}
          return 1

        end
      end

      #todo check force option, only override if not existing, else raise and exit
      def create_config
        FileUtils.cp(File.join(File.dirname(__FILE__), "..", "config", CONFIG_DEFAULT_NAME), File.join(Dir.pwd, CONFIG_DEFAULT_NAME))
      end


      def build_options(arguments)
        env_opts_string = ENV['TERRIMPORTER_OPTS'] || ""
        env_opts = TerrImporter::Application::Options.new(shellwords(env_opts_string))
        argument_opts = TerrImporter::Application::Options.new(arguments)
        env_opts.merge(argument_opts)
      end
    end
  end
end

