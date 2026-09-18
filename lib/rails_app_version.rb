# frozen_string_literal: true

require "rails"
require "rails/application"
require "action_controller/railtie"
require "rails_app_version/version"
require "rails_app_version/app_info"
require "rails_app_version/railtie"

module RailsAppVersion
  extend ActiveSupport::Autoload

  autoload :AppInfoMiddleware
end
