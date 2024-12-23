require "test_helper"

module RailsAppVersion
  class VersionTest < ActiveSupport::TestCase
    def setup
      @version_three_parts = Version.create("1.2.3")
      @version_two_parts = Version.create("1.2")
      @pre_version = Version.create("2.0.0-alpha")
      @version_with_revision = Version.create("1.2.3", "abc123def456")
    end

    test "parses major and minor versions" do
      assert_equal 1, @version_two_parts.major
      assert_equal 2, @version_two_parts.minor
      assert_nil @version_two_parts.patch
    end

    test "parses major, minor, and patch versions" do
      assert_equal 1, @version_three_parts.major
      assert_equal 2, @version_three_parts.minor
      assert_equal 3, @version_three_parts.patch
    end

    test "handles prerelease versions" do
      assert_equal 2, @pre_version.major
      assert_equal 0, @pre_version.minor
      assert_equal 0, @pre_version.patch
      assert_equal "alpha", @pre_version.pre
    end

    test "detects prerelease versions" do
      assert_not @version_three_parts.prerelease?
      assert_not @version_two_parts.prerelease?
      assert @pre_version.prerelease?
    end

    test "determines production readiness" do
      assert @version_three_parts.production_ready?
      assert @version_two_parts.production_ready?
      assert_not @pre_version.production_ready?
      assert_not Version.create("0.1.0").production_ready?
    end

    test "provides standard version string without revision" do
      assert_equal "1.2.3", @version_with_revision.to_s
    end

    test "includes revision only in full version string" do
      assert_equal "1.2.3 (abc123de)", @version_with_revision.full
    end

    test "generates cache key without revision" do
      assert_equal "1-2-3", @version_with_revision.to_cache_key
      assert_equal "1-2", @version_two_parts.to_cache_key
      assert_equal "2-0-0-alpha", @pre_version.to_cache_key
    end

    test "maintains compatibility with Gem::Version comparison" do
      assert Version.create("2.0") > Version.create("1.9")
      assert Version.create("1.2") < Version.create("1.2.1")
      assert Version.create("1.2.0") == Version.create("1.2")
      # Revision should not affect comparison
      assert Version.create("1.2.0", "abc") == Version.create("1.2.0", "def")
    end
  end
end
