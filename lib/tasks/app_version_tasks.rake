# lib/tasks/app_version_tasks.rake
namespace :app do
  namespace :version do
    desc "Copy config/app_version.yml to the main app config directory"
    task :config do
      source = RailsAppVersion::Railtie.root.join("config", RailsAppVersion::Railtie::CONFIG_FILE)
      destination = Rails.root.join("config", RailsAppVersion::Railtie::CONFIG_FILE)

      if File.exist?(destination)
        puts "Config file already exists at #{destination}"
        print "Overwrite? (y/n): "
        next unless $stdin.gets.strip.downcase == "y"
      end

      FileUtils.cp(source, destination)
      puts "Installed #{RailsAppVersion::Railtie::CONFIG_FILE} to #{destination}"
    end

    desc "Display current application version information"
    task info: :environment do
      puts "Application version: #{Rails.application.version}"
      puts "Environment: #{Rails.application.env}"
      puts "Config: #{Rails.application.app_config.inspect}"
    end
  end
end
