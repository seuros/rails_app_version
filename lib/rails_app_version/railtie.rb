module RailsAppVersion
  class Railtie < ::Rails::Railtie
    class << self
      def root
        @root ||= Pathname.new(File.expand_path(File.expand_path("../../", __dir__)))
      end
    end

    attr_reader :app_config, :version, :env

    rake_tasks do
      namespace :app do
        namespace :version do
          desc "Copy config/app_version.yml to the main app config directory"
          task :config do
            source = Railtie.root.join("config", "app_version.yml")
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
                    rescue RuntimeError => e # file is not found
                      # Load the default configuration from the gem
                      require "erb"
                      yaml = Railtie.root.join("config", "app_version.yml")
                      all_configs = ActiveSupport::ConfigurationFile.parse(yaml).deep_symbolize_keys
                      all_configs[:shared]
                    end
      @version = RailsAppVersion::Version.create(@app_config[:version], @app_config[:revision])
      @env = ActiveSupport::StringInquirer.new(@app_config.fetch(:environment, Rails.env))
    end

    initializer "middleware" do |app|
      # Add the middleware to the stack if enabled
      if @app_config.dig(:middleware, :enabled)
        options = @app_config.dig(:middleware, :options) || {}
        app.middleware.insert_before Rails::Rack::Logger, RailsAppVersion::AppInfoMiddleware, **options
      end
    end
  end
end
