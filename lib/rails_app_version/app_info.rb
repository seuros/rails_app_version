# frozen_string_literal: true

module RailsAppVersion
  # Mixed into Rails::Application so `Rails.application.version`,
  # `.env` and `.app_config` read straight off the railtie instance that
  # parsed app_version.yml.
  module AppInfo
    def version = app_version_railtie.version
    def env = app_version_railtie.env
    def app_config = app_version_railtie.app_config

    private

    def app_version_railtie
      @app_version_railtie ||= railties.find { |railtie| railtie.is_a?(RailsAppVersion::Railtie) }
    end
  end
end
