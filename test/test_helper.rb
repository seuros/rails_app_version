# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"
require "mocha/minitest"

# load tasks
Rails.application.load_tasks

puts "Rails version: #{Rails.version}"
