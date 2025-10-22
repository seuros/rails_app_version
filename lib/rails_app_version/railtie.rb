# frozen_string_literal: true

module RailsAppVersion
  Rails::Application.include AppEnvironment
  Rails::Application.include AppVersion
  class Railtie < ::Rails::Railtie
    CONFIG_FILE = "app_version.yml".freeze

    class << self
      def root
        @root ||= Pathname.new(File.expand_path(File.expand_path("../../", __dir__)))
      end
    end

    attr_reader :app_config, :version, :env

    rake_tasks do
      load File.expand_path("../../tasks/app_version_tasks.rake", __FILE__)
    end

    console do
      print_console_banner
    end

    initializer "rails_app_version.fetch_config" do |app|
      @app_config = load_config(app)
      @version = Version.create(@app_config[:version], @app_config[:revision])
      @env = ActiveSupport::StringInquirer.new(@app_config.fetch(:environment, Rails.env))
    end

    initializer "rails_app_version.middleware" do |app|
      # Add the middleware to the stack if enabled
      if @app_config.dig(:middleware, :enabled)
        options = @app_config.dig(:middleware, :options) || {}
        app.middleware.insert_before Rails::Rack::Logger, AppInfoMiddleware, options
      end
    end

    private

    def load_config(app)
      app.config_for(:app_version, env: Rails.env)
    rescue StandardError => e
      Rails.logger.warn("Could not load app_version.yml: #{e.message}. Using default configuration.")
      load_default_config
    end

    def load_default_config
      yaml_path = Railtie.root.join("config", CONFIG_FILE)
      all_configs = parse_yaml_config(yaml_path)
      all_configs[:shared] || {}
    end

    def parse_yaml_config(path)
      return {} unless File.exist?(path)

      require "erb"
      ActiveSupport::ConfigurationFile.parse(path).deep_symbolize_keys
    end

    def self.print_console_banner
      # rubocop:disable Rails/Output
      puts "Welcome to the Rails console!"
      puts "Ruby version: #{RUBY_VERSION}"
      puts "Application environment: #{Rails.application.env}"
      puts "Application version: #{Rails.application.version&.full}"
      puts "To exit, press `Ctrl + D`."
      # rubocop:enable Rails/Output
    end
  end
end
