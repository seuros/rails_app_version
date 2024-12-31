# frozen_string_literal: true

require "test_helper"

module RailsAppVersion
  class AppInfoMiddlewareTest < ActiveSupport::TestCase
    def setup
      @app = ->(env) { [ 200, {}, [ "OK" ] ] }
      @version = Version.create("8.0.3", "abc123def456")
      @env = "sandbox"

      Rails.application.stubs(:version).returns(@version)
      Rails.application.stubs(:env).returns(@env)
    end

    def teardown
      Rails.application.unstub(:version)
      Rails.application.unstub(:env)
    end

    test "adds default version and environment headers" do
      middleware = AppInfoMiddleware.new(@app)
      status, headers, response = middleware.call({})

      assert_equal "8.0.3 (abc123de)", headers["X-App-Version"]
      assert_equal "sandbox", headers["X-App-Environment"]
      assert_equal 200, status
      assert_equal [ "OK" ], response
    end

    test "allows custom header names" do
      middleware = AppInfoMiddleware.new(@app, {
        version_header: "X-Custom-Version",
        environment_header: "X-Custom-Environment"
      })

      _, headers, _ = middleware.call({})

      assert_equal "8.0.3 (abc123de)", headers["X-Custom-Version"]
      assert_equal "sandbox", headers["X-Custom-Environment"]
    end

    test "includes revision in version header when configured" do
      middleware = AppInfoMiddleware.new(@app, {
        include_revision: true
      })

      _, headers, _ = middleware.call({})

      assert_equal "8.0.3 (abc123de)", headers["X-App-Version"]
    end

    test "ignores include_revision when version has no revision" do
      version_without_revision = Version.create("8.0.3")
      Rails.application.stubs(:version).returns(version_without_revision)

      middleware = AppInfoMiddleware.new(@app, {
        include_revision: true
      })

      _, headers, _ = middleware.call({})

      assert_equal "8.0.3", headers["X-App-Version"]
    end
  end

  class AppInfoMiddlewareIntegrationTest < ActionDispatch::IntegrationTest
    test "adds default version and environment headers" do
      get "/"

      assert_response :success
      assert_equal "8.0.3 (c1be795b)", response.headers["X-App-Version"]
      assert_equal "sandbox", response.headers["X-App-Environment"]
    end
  end
end
