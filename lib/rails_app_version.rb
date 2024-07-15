# frozen_string_literal: true

require "rails"
require "rails/application"
require "rails_app_version/version"

module RailsAppVersion
  class Engine < ::Rails::Engine
    attr_reader :app_config, :version, :environment

    initializer "fetch_config" do |app|
      @app_config = begin
        app.config_for(:app_version)
      rescue RuntimeError
        # Load the default configuration from the gem, if the app does not have one
        require "erb"
        yaml = Engine.root.join("config", "app_version.yml")
        all_configs = ActiveSupport::ConfigurationFile.parse(yaml).deep_symbolize_keys
        all_configs[:shared]
                    end

      @version = @app_config[:version]
      @environment = @app_config[:environment] || Rails.env
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
      def environment
        @environment ||= railties.find do |railtie|
          railtie.is_a?(RailsAppVersion::Engine)
        end.environment
      end
    end
  end
end


Rails::Application.include RailsAppVersion::AppVersion
Rails::Application.include RailsAppVersion::AppEnvironment
