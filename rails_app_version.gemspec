# frozen_string_literal: true

require_relative 'lib/rails_app_version/version'

Gem::Specification.new do |spec|
  spec.name        = 'rails_app_version'
  spec.version     = RailsAppVersion::VERSION
  spec.authors     = [ 'Abdelkader Boudih' ]
  spec.email       = [ 'terminale@gmail.com' ]
  spec.homepage    = 'https://github.com/seuros/rails_app_version'
  spec.summary     = 'Get the version of your Rails app'
  spec.description = spec.summary

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 3.1.0'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{config,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'railties', '>= 7', '< 9'
  spec.add_development_dependency 'dotenv-rails'
  spec.add_development_dependency "appraisal"
end
