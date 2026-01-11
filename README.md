# Rails AppVersion

Rails AppVersion provides an opinionated version and environment management for your Rails applications. By exposing
version and environment information throughout your application, it enables better error tracking, debugging, and
deployment management.

## Why Use Rails AppVersion?

Version and environment tracking are important for modern web applications, particularly when debugging issues in
production. Rails AppVersion helps you:

- Track errors with version context in error reporting services
- Identify which version of your application is running in each environment
- Cache bust assets between versions
- Verify deployment success across environments
- Avoid homegrown version management solutions

### Error Reporting Integration Example

Using [Lapsoss](https://github.com/seuros/lapsoss) - a vendor-neutral error reporting gem:

```ruby
# config/initializers/lapsoss.rb
Lapsoss.configure do |config|
  # Works with any service - switch vendors without code changes
  config.use_telebugs(dsn: ENV['TELEBUGS_DSN'])

  # Set release and environment from Rails AppVersion
  config.release = Rails.application.version.to_s
  config.environment = Rails.application.env
end
```

### Cache Management Example

```ruby

class AssetManifest
  def asset_path(path)
    "/assets/#{path}?v=#{Rails.application.version.to_cache_key}"
  end
end

# Or in your controller

def index
  Rails.cache.fetch("index-page#{Rails.application.version.to_cache_key}") do
    render :index
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails_app_version"
```

Then execute:

```bash
$ bundle install
$ rails app:version:config  # Copies the default configuration file
$ echo "1.0.0" > VERSION    # Create initial version file
```

## Version Management

Rails AppVersion supports two methods for managing your application's version:

### Recommended: Using a VERSION File

The recommended approach is to maintain a `VERSION` file in your application's root directory. This file should contain
only the version number:

```plaintext
1.2.3
```

This approach offers several advantages:

- Clear version history in source control
- Easy automated updates during deployment
- Separation of version from configuration
- Compatibility with CI/CD pipelines

### Alternative: Configuration in YAML

While not recommended for production applications, you can also specify the version directly in the configuration file.
The default configuration file is located at `config/app_version.yml`:

```yaml
shared:
  # Attempts to read from VERSION file, falls back to '0.0.0'
  version: <%= Rails.root.join('VERSION').read.strip rescue '0.0.0' %>
  # Attempts to read from REVISION file, then tries git commit hash, finally falls back to '0'
  revision: <%= Rails.root.join('REVISION').read.strip rescue (`git rev-parse HEAD`.strip rescue '0') %>
  show_revision: <%= Rails.env.local? %>
  environment: <%= ENV.fetch('RAILS_APP_ENV', Rails.env) %>
```

You can customize this configuration for different environments, though we recommend maintaining version information in
the VERSION file:

```yaml
shared:
  # Not recommended: hardcoding version in YAML
  version: '1.2.3'
  environment: production

development:
  environment: local
  show_revision: true

staging:
  environment: staging
```

## Usage

### Accessing Version Information

```ruby
# Get the current version
Rails.application.version.to_s # => "1.2.3"

# Check version components
Rails.application.version.major # => 1
Rails.application.version.minor # => 2
Rails.application.version.patch # => 3

# Check version status
Rails.application.version.production_ready? # => true
Rails.application.version.prerelease? # => false

# Get a cache-friendly version string
Rails.application.version.to_cache_key # => "1-2-3"
```

## Version Headers Middleware

Rails AppVersion includes an optional middleware that adds version and environment information to HTTP response headers.
This is particularly useful in staging and pre-production environments to verify deployment success and track which version
of the application is serving requests.

### Configuring the Middleware

Enable and configure the middleware in your `config/app_version.yml`:

```yaml
development:
  middleware:
    enabled: false

staging:
  middleware:
    enabled: true
    options:
      version_header: X-Staging-Version
      environment_header: X-Staging-Environment
```

### Manual Middleware Configuration

You can also add the middleware manually in your application configuration:

```ruby
# config/application.rb or config/environments/staging.rb
config.middleware.use RailsAppVersion::AppInfoMiddleware, {
  version_header: 'X-Custom-Version',
  environment_header: 'X-Custom-Environment'
}
```

The middleware will add the following headers to each response:

- X-App-Version: Current application version, optionally including revision (e.g., "1.2.3" or "1.2.3 (abc123de)")
- X-App-Environment: Current environment (e.g., "staging")

When `show_revision` is enabled, the version header will include the first 8 characters of the git revision in
parentheses. This provides a quick way to verify both the version and the specific deployment in a single header.

This makes it easy for developers to verify which version is deployed and running in each environment, particularly
useful during deployments and debugging.

### Environment Management

```ruby
# Get the current environment
Rails.application.env # => "staging"

# Environment checks
Rails.application.env.production? # => false
Rails.application.env.staging? # => true
```

### Console Integration

The gem automatically displays version and environment information when you start a Rails console:

```
Welcome to the Rails console!
Ruby version: 3.2.0
Application environment: staging
Application version: 1.2.3
To exit, press `Ctrl + D`.
```

## Version Format

Rails AppVersion supports several version formats:

- Standard versions: "1.2.3" (major.minor.patch)
- Short versions: "1.2" (major.minor)
- Pre-release versions: "2.0.0-alpha" (with pre-release identifier)

Version strings are parsed according to Semantic Versioning principles and maintain compatibility with `Gem::Version`
for comparison operations.

## Using with release-please
To have release-please automatically update a plain VERSION file in your repository:
1. Add the inline marker to your VERSION file:
```
1.0.0
```

2. Configure release-please

Add the following to .github/release-please-config.json:
```json
{
  "packages": {
    ".": {
      "release-type": "simple",
      "component": "App Name",
      "version-file": "VERSION"
    }
  }
}
```

3. Add the following to .github/release-please-manifest.json:
```json
{
    ".": "1.0.0"
}
```

4. Add the following to .github/workflows/release-please.yml:
```yaml
name: release-please

on:
  push:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.RELEASE_PLEASE_TOKEN }}
          config-file: .github/release-please-config.json
          manifest-file: .github/.release-please-manifest.json
```

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for your changes
4. Make your changes and ensure tests pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request

Please ensure your changes include appropriate tests and documentation.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
