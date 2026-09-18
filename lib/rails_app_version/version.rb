# frozen_string_literal: true

module RailsAppVersion
  VERSION = "1.5.0"

  # A Gem::Version with named segments, an optional VCS revision and cache-key
  # helpers.
  #
  # Segment parsing is delegated to Gem::Version, so "2.0.0-alpha",
  # "2.0.0.alpha" and "2.0.0.pre.alpha" all describe the same prerelease, and
  # malformed strings raise instead of silently parsing as 0.
  class Version < Gem::Version
    # Deploy scripts write "0" to REVISION when no SHA is available.
    BLANK_REVISION = "0"

    attr_accessor :revision

    def self.create(version_string, revision = nil)
      raise ArgumentError, "Version string cannot be nil or empty" if version_string.to_s.strip.empty?

      new(version_string).tap { |version| version.revision = revision }
    end

    def major = numeric_segments[0] || 0
    def minor = numeric_segments[1] || 0
    def patch = numeric_segments[2]

    # The prerelease label, without the "pre" marker Gem::Version inserts:
    # "2.0.0-alpha" => "alpha", "1.2.3" => nil.
    def pre
      return @pre if defined?(@pre)

      @pre = segments.drop(numeric_segments.size).reject { |segment| segment == "pre" }.join(".").presence
    end

    def full
      short_revision ? "#{self} (#{short_revision})" : to_s
    end

    def short_revision
      return if revision.to_s == BLANK_REVISION

      revision.to_s.slice(0, 8).presence
    end

    def to_cache_key
      parts = [ major, minor ]
      parts << patch if patch
      parts << pre if prerelease?
      parts.join("-")
    end

    def production_ready? = !prerelease? && major.positive?

    private

    def numeric_segments
      @numeric_segments ||= segments.take_while { |segment| segment.is_a?(Integer) }
    end
  end
end
