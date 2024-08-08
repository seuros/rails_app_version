# Rails AppVersion

Rails AppVersion is a Ruby on Rails engine designed to easily manage and access your application's version and environment information. 

It allows for a seamless integration of versioning within your Rails application, providing a straightforward way to access the current application version and environment without hardcoding these values.

This gem is exclusively build for Rails applications and is compatible with Rails 7.0 and above.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "rails_app_version"
```

And then execute:
```bash
$ bundle
```

## Usage:
    After adding the gem, you can access the application version and environment information anywhere in your Rails application.
```ruby
Rails.application.version # => "1.0.0"
Rails.application.env # => "staging"
```

## Features
- Easy Configuration: Set up your application version and environment in a simple YAML file.
- Automatic Integration: The engine automatically integrates with your Rails application, making the version and environment information accessible.
- Flexible Usage: Access the application version and environment information anywhere in your Rails application.

## Contributing
Contributions are welcome, and they are greatly appreciated! Every little bit helps, and credit will always be given.
1. Fork the repo
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
