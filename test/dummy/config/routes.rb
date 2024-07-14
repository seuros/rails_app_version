Rails.application.routes.draw do
  mount RailsAppVersion::Engine => "/rails_app_version"
end
