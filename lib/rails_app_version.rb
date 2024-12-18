# frozen_string_literal: true

require "rails"
require "rails/application"
require "rails_app_version/version"
require "rails_app_version/railtie"
require "rails_app_version/app_version"
require "rails_app_version/app_environment"
require "rails_app_version/version"
require "action_controller/railtie"

module RailsAppVersion
  class Version < Gem::Version
    attr_reader :major, :minor, :patch, :pre

    def initialize(version_string)
      super
      parse_version(version_string)
    end

    def to_cache_key
      parts = [ major, minor ]
      parts << patch if has_patch?
      parts << pre if prerelease?
      parts.join("-")
    end

    def prerelease?
      !@pre.nil?
    end

    def production_ready?
      !prerelease? && major.positive?
    end

    def has_patch?
      !@patch.nil?
    end

    private

    def parse_version(version_string)
      if version_string.nil? || version_string.empty?
        raise ArgumentError, "Version string cannot be nil or empty"
      end

      parts = version_string.split(".")
      pre_parts = parts.last.split("-")

      if pre_parts.length > 1
        parts[-1] = pre_parts[0]
        @pre = pre_parts[1]
      end

      @major = parts[0].to_i
      @minor = parts[1]&.to_i || 0
      @patch = parts[2]&.to_i
    end
  end
end

Rails::Application.include RailsAppVersion::AppVersion
Rails::Application.include RailsAppVersion::AppEnvironment
