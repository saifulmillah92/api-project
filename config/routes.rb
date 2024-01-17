require_relative 'routes_helpers'
require 'sidekiq/web'

Rails.application.routes.draw do
  extend RoutesHelpers
  default_url_options host: ENV.fetch("API_HOST", nil)
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

  # root not found
  get      '/' => "errors#route_not_found"

  # AUTHENTICATION
  get      'auth'         => 'auth#index'
  # LOGIN #
  post     'auth/sign-in' => 'auth#login'
  # FORGOT PASSWORD
  post     'auth/forgot-password' => 'auth#forgot_password'
  post     'auth/reset-password' => 'auth#reset_password'

  api(:v1, module: "v1") do
    # Upload
    post 'uploads'                   => 'uploads#create'
    get  'uploads/presign'           => 'uploads#presign'

    #################### USER MANAGEMENT ####################
    # USERS
    get     'users'         => 'users#index'
    get     'users/:id'     => 'users#show'
    post    'users'         => 'users#create'
    put     'users/:id'     => 'users#update'
    delete  'users/:id'     => 'users#destroy'

    # ROLES
    get     'roles'        => "roles#index"
    post    'roles'        => "roles#create"
    get     'roles/:id'    => "roles#show"
    patch   'roles/:id'    => "roles#update"
    delete  'roles/:id'    => "roles#destroy"
    #################### USER MANAGEMENT ####################

    # Notifications
    get 'notifications'         => "notifications#index"
    put 'notifications/:id'     => "notifications#see"

    #################### SETTINGS ####################

    scope :settings, module: :settings do
      #################### APPLICATION CONFIGURATION ####################
      get      'configs'             => 'configs#index'
      patch    'configs/:id'         => 'configs#update'
      #################### APPLICATION CONFIGURATION ####################
    end

    #################### SETTINGS ####################
  end

  # HANDLE ROOT NOT FOUND #
  match '*path' => 'errors#route_not_found', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
