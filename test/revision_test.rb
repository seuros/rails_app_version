# frozen_string_literal: true

require "test_helper"

module RailsAppVersion
  class RevisionTest < ActiveSupport::TestCase
    setup do
      @railtie = Rails.application.send(:app_version_railtie)
      @deployed_revision = Rails.root.join("REVISION").read.strip
    end

    test "prefers an explicit revision from app_version.yml" do
      assert_equal "deadbeefcafe", @railtie.send(:revision_for, Rails.application, { revision: "deadbeefcafe" })
    end

    test "defers to Rails when app_version.yml leaves the revision blank" do
      assert_equal @deployed_revision, @railtie.send(:revision_for, Rails.application, {})
      assert_equal @deployed_revision, @railtie.send(:revision_for, Rails.application, { revision: nil })
    end

    test "exposes the resolved revision on the application version" do
      assert_equal @deployed_revision, Rails.application.version.revision
      assert_equal @deployed_revision.slice(0, 8), Rails.application.version.short_revision
    end
  end
end
