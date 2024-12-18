# frozen_string_literal: true

module RailsAppVersion
  module AppEnvironment
    extend ActiveSupport::Concern

    included do
      def env
        @env ||= railties.find do |railtie|
          railtie.is_a?(RailsAppVersion::Railtie)
        end.env
      end
    end
  end
end
