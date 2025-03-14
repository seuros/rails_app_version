# frozen_string_literal: true

require "rails"
require "rails/application"
require "rails_app_version/version"
require "rails_app_version/app_version"
require "rails_app_version/app_environment"
require "action_controller/railtie"
require "rails_app_version/railtie"

module RailsAppVersion
  extend ActiveSupport::Autoload

  autoload :AppInfoMiddleware
end
