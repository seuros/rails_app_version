# frozen_string_literal: true

module RailsAppVersion
  class AppInfoMiddleware
    DEFAULT_OPTIONS = {
      version_header: "X-App-Version",
      environment_header: "X-App-Environment"
    }.freeze

    def initialize(app, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @app = app
    end

    def call(env)
      # Call the next middleware in the chain first
      status, headers, response = @app.call(env)

      # Add our custom headers to the response
      headers[@options[:version_header]] = Rails.application.version.full
      headers[@options[:environment_header]] = Rails.application.env

      # Return the modified response
      [ status, headers, response ]
    end
  end
end
