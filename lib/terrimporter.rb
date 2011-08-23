require 'shellwords'
require 'terrimporter/options'
require 'terrimporter/importer'
require 'terrimporter/version'
require 'terrimporter/config_helper'
require 'terrimporter/downloader'

module TerrImporter
  class Application
    class << self
      include Shellwords
      include ConfigHelper

      def run!(*arguments)
        options = build_options(arguments)

        begin
          if options[:init]
            if config_working_directory_exists?
              raise TerrImporter::ConfigurationError "Configuration already exists, use the override or backup option"
            end
            create_config_file
            return 0
          end

          if options[:invalid_argument]
            $stderr.puts options[:invalid_argument]
            options[:show_help] = true
          end

          if options[:show_help]
            $stderr.puts options.opts
            return 1
          end

          importer = TerrImporter::Application::Importer.new(options)
          importer.run
          return 0
        rescue TerrImporter::ConfigurationError
          $stderr.puts %Q{Configuration Error #{ $!.message }}
          return 1
        rescue TerrImporter::DefaultError
          $stderr.puts %Q{Unspecified Error #{ $!.message }}
          return 1
        end
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

