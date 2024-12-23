# frozen_string_literal: true

module RailsAppVersion
  class AppInfoMiddleware
    DEFAULT_OPTIONS = {
      version_header: "X-App-Version",
      environment_header: "X-App-Environment",
      revision_header: "X-App-Revision",
      include_revision: false
    }.freeze

    def initialize(app, options = {})
      @app = app
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def call(env)
      status, headers, response = @app.call(env)

      headers[@options[:version_header]] = Rails.application.version.full
      headers[@options[:environment_header]] = Rails.application.env

      [ status, headers, response ]
    end
  end
end
