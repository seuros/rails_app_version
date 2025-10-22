# frozen_string_literal: true

module RailsAppVersion
  VERSION = "1.4.0"

  class Version < Gem::Version
    attr_reader :major, :minor, :patch, :pre, :revision

    def self.create(version_string, revision = nil)
      new(version_string).tap { |v| v.set_revision(revision) }
    end

    def set_revision(revision)
      @revision = revision
    end

    def full
      return to_s unless revision
      return to_s if revision.to_s == "0"
      "#{self} (#{short_revision})"
    end

    def to_cache_key
      parts = [ major, minor ]
      parts << patch if has_patch?
      parts << pre if prerelease?
      parts.join("-")
    end

    def short_revision
      revision.to_s.slice(0, 8).presence
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

    protected

    def initialize(version)
      super
      parse_version(version)
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
