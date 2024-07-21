# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"

# load tasks
Rails.application.load_tasks

puts "Rails version: #{Rails.version}"
