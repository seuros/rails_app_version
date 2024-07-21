Rails.application.routes.draw do
  # root return ok
  get "/", to: proc { [ 200, {}, [ "" ] ] }
end
