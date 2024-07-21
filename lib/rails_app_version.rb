# frozen_string_literal: true

require "rails"
require "rails/application"
require "rails_app_version/version"

module RailsAppVersion
  class Version < Gem::Version
    # This method cache used by Rails.cache.fetch to generate a cache key
    def to_cache_key
      (to_s).parameterize
    end
  end

  class Engine < ::Rails::Engine
    load "tasks/rails_app_version.rake"
    attr_reader :app_config, :version, :env

    initializer "fetch_config" do |app|
      @app_config = begin
        app.config_for(:app_version, env: Rails.env)
      rescue RuntimeError
        # Load the default configuration from the gem, if the app does not have one
        require "erb"
        yaml = Engine.root.join("config", "app_version.yml")
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
          railtie.is_a?(RailsAppVersion::Engine)
        end.version
      end
    end
  end

  module AppEnvironment
    extend ActiveSupport::Concern

    included do
      def env
        @env ||= railties.find do |railtie|
          railtie.is_a?(RailsAppVersion::Engine)
        end.env
      end
    end
  end
end

Rails::Application.include RailsAppVersion::AppVersion
Rails::Application.include RailsAppVersion::AppEnvironment
