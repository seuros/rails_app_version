# frozen_string_literal: true

require "test_helper"

class AppVersionRakeTaskTest < ActiveSupport::TestCase
  setup do
    # Setup test environment
    @source = RailsAppVersion::Engine.root.join("config", "app_version.yml")
    @destination = Rails.root.join("config", "app_version.yml")
  end

  test "app_version:config task copies app_version.yml to the main app's config directory" do
    # Ensure the destination file does not exist before the task
    FileUtils.rm_f(@destination)

    # Invoke the task
    out, _ = capture_io do
      Rake::Task["app:version:config"].invoke
    end

    # Check the file was copied
    assert File.exist?(@destination), "The app_version.yml file should have been copied to the main app's config directory."

    # verify the contents if necessary
    assert_equal File.read(@source), File.read(@destination), "The contents of the copied file should match the source."
  end

  teardown do
    FileUtils.rm_f(@destination)
  end
end
