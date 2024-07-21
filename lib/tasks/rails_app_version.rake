# lib/tasks/app_version.rake
require "fileutils"

namespace :app do
  namespace :version do
    desc "Copy config/app_version.yml to the main app config directory"
    task :config do
      source = RailsAppVersion::Engine.root.join("config", "app_version.yml")
      destination = Rails.root.join("config", "app_version.yml")

      FileUtils.cp(source, destination)

      puts "Installed app_version.yml to #{destination}"
    end
  end
end
