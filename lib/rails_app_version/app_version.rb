# frozen_string_literal: true

module RailsAppVersion
  module AppVersion
    extend ActiveSupport::Concern

    included do
      def version
        @version ||= railties.find do |railtie|
          railtie.is_a?(RailsAppVersion::Railtie)
        end.version
      end
    end
  end
end
