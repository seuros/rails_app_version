# frozen_string_literal: true

require "rails"
require "rails/application"
require "rails_app_version/version"
require "action_controller/railtie"

module RailsAppVersion
  class Version < Gem::Version
    # This method cache used by Rails.cache.fetch to generate a cache key
    def to_cache_key
      (to_s).parameterize
    end
  end
  class Railtie < ::Rails::Railtie
    attr_reader :app_config, :version, :env

    def root
      @root ||= Pathname.new(File.expand_path("..", __dir__))
    end

    rake_tasks do
      namespace :app do
        namespace :version do
          desc "Copy config/app_version.yml to the main app config directory"
          task :config do
            source = RailsAppVersion::Railtie.root.join("config", "app_version.yml")
            destination = Rails.root.join("config", "app_version.yml")

            FileUtils.cp(source, destination)

            puts "Installed app_version.yml to #{destination}"
          end
        end
      end
    end

    # Console
    console do
      # rubocop:disable Rails/Output
      puts "Welcome to the Rails console!"
      puts "Ruby version: #{RUBY_VERSION}"
      puts "Application environment: #{Rails.application.env}"
      puts "Application version: #{Rails.application.version}"
      puts "To exit, press `Ctrl + D`."
      # rubocop:enable Rails/Output
    end

    initializer "fetch_config" do |app|
      @app_config = begin
        app.config_for(:app_version, env: Rails.env)
      rescue RuntimeError
        # Load the default configuration from the gem, if the app does not have one
        require "erb"
        yaml = Railtie.root.join("config", "app_version.yml")
        all_configs = ActiveSupport::ConfigurationFile.parse(yaml).deep_symbolize_keys
        all_configs[:shared]
                    end

      @version = Version.new(@app_config[:version])
      @env = ActiveSupport::StringInquirer.new(@app_config[:environment] || Rails.env)
    end
  end

  module AppVersion
    extend ActiveSupport::Concern

    included do
      def version
        @version ||= railties.find do |railtie|
          railtie.is_a?(RailsAppVersion::Railtie)
        end.version
      end
    end
  end

  module AppEnvironment
    extend ActiveSupport::Concern

    included do
      def env
        @env ||= railties.find do |railtie|
          railtie.is_a?(RailsAppVersion::Railtie)
        end.env
      end
    end
  end
end

Rails::Application.include RailsAppVersion::AppVersion
Rails::Application.include RailsAppVersion::AppEnvironment
