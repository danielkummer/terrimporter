require 'shellwords'
require 'terrimporter/application_helper'
require 'terrimporter/version'
require 'terrimporter/download_helper'
require 'terrimporter/app_logger'
require 'terrimporter/options'
require 'terrimporter/importer_helper'
require 'terrimporter/importer'
require 'terrimporter/configuration_helper'
require 'terrimporter/configuration'
require 'terrimporter/downloader'
require 'terrimporter/string_monkeypatch'
require 'terrimporter/array_monkeypatch'
require 'etc'
require 'kwalify'
require 'fileutils'
require 'yaml'
require 'uri'

module TerrImporter
  class Application
    class << self
      include Shellwords
      include ConfigurationHelper
      include ApplicationHelper

      def run!(*arguments)
        options = build_options(arguments)

        begin
          if !options[:init].nil?
            if config_working_directory_exists? and options[:init] != :backup and options[:init] != :replace
              raise TerrImporter::ConfigurationError, "Configuration already exists, use the override or backup option"
            end
            create_config_file(options[:init], options[:application_url])
            return 0
          end

          case options[:verbose]
            when true
              LOG.level = :debug
            when false
              LOG.level = :info
          end


          if options[:invalid_argument]
            $stderr.puts options[:invalid_argument]
            options[:show_help] = true
          end

          if options[:invalid_option]
            $stderr.puts options[:invalid_option]
            options[:show_help] = true
          end

          if options[:show_help]
            $stderr.puts options.opts
            return 1
          end

          if options[:show_version]
            puts TerrImporter::VERSION
            return 0
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

