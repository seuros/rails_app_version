require_relative "boot"

require "rails"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # Pinned to the oldest supported Rails so the edge appraisal doesn't fail
    # on defaults that only exist on main.
    config.load_defaults 8.0
    config.api_only = true
  end
end
