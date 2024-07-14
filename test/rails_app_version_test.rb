# frozen_string_literal: true

require "test_helper"

class RailsAppVersionTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Rails.application
    assert_respond_to Rails.application, :version

    assert_equal Gem::Version.create("8.0.3"), Rails.application.version
  end

  test "it has an environment" do
    assert Rails.application
    assert_respond_to Rails.application, :environment

    assert_equal "test", Rails.application.environment
  end
end
