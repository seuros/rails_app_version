# frozen_string_literal: true

require "test_helper"

class RailsAppVersionTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert_respond_to Rails.application, :version

    assert_equal Gem::Version.create("8.0.3"), Rails.application.version
  end

  test "it has an environment" do
    assert_respond_to Rails.application, :env

    assert_equal "sandbox", Rails.application.env
    assert Rails.application.env.sandbox?
  end
end
