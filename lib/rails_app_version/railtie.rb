# frozen_string_literal: true

module RailsAppVersion
  Rails::Application.include AppInfo

  class Railtie < ::Rails::Railtie
    CONFIG_FILE = "app_version.yml"

    class << self
      def root
        @root ||= Pathname.new(File.expand_path("../..", __dir__))
      end

      def print_console_banner
        # rubocop:disable Rails/Output
        puts "Welcome to the Rails console!"
        puts "Ruby version: #{RUBY_VERSION}"
        puts "Application environment: #{Rails.application.env}"
        puts "Application version: #{Rails.application.version.full}"
        puts "To exit, press `Ctrl + D`."
        # rubocop:enable Rails/Output
      end
    end

    attr_reader :app_config, :version, :env

    rake_tasks do
      load File.expand_path("../tasks/app_version_tasks.rake", __dir__)
    end

    console do
      print_console_banner
    end

    initializer "rails_app_version.fetch_config" do |app|
      @app_config = load_config(app)
      @version = Version.create(@app_config[:version], revision_for(app, @app_config))
      @env = ActiveSupport::StringInquirer.new(@app_config.fetch(:environment, Rails.env))
    end

    initializer "rails_app_version.middleware" do |app|
      next unless @app_config.dig(:middleware, :enabled)

      options = @app_config.dig(:middleware, :options) || {}
      app.middleware.insert_before Rails::Rack::Logger, AppInfoMiddleware, options
    end

    private

    # An explicit revision in app_version.yml always wins. Otherwise defer to
    # Rails::Application#revision (8.2+), which already resolves
    # ENV["REVISION"], the REVISION file, then `git rev-parse HEAD`. There is
    # no reason for this gem to reimplement that.
    def revision_for(app, config)
      return config[:revision] if config[:revision].present?
      return app.revision if app.respond_to?(:revision)

      # Rails < 8.2 has no native lookup. Deliberately no `git rev-parse`
      # fallback: ship a REVISION file or set ENV["REVISION"] instead of
      # shelling out on every boot. Remove once 8.2 is the minimum.
      ENV["REVISION"].presence || read_revision_file(app)
    end

    def read_revision_file(app)
      app.root.join("REVISION").read.strip.presence
    rescue SystemCallError
      nil
    end

    # Falls back to the config shipped with the gem when the host app has no
    # config/app_version.yml. `rake app:version:config` installs one.
    def load_config(app)
      app.config_for(:app_version, env: Rails.env)
    rescue StandardError => e
      Rails.logger&.warn("Could not load #{CONFIG_FILE}: #{e.message}. Using default configuration.")
      default_config
    end

    def default_config
      path = Railtie.root.join("config", CONFIG_FILE)
      return {} unless File.exist?(path)

      ActiveSupport::ConfigurationFile.parse(path).deep_symbolize_keys[:shared] || {}
    end
  end
end
