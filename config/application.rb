require_relative "boot"
require_relative "../lib/subdomain_tenant_middleware"
require_relative "../lib/env_loader"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApiProject
  class Application < Rails::Application
    # load Environtment
    EnvLoader.load
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_job.queue_adapter = :sidekiq

    # Actioncable config
    # config.action_cable.disable_request_forgery_protection = true
    config.action_cable.allowed_request_origins = [%r{http://*}, %r{https://*}, nil]
    config.action_cable.url = "/cable"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join("lib")

    config.cache_store =
      :redis_cache_store, {
        host: ENV.fetch("REDIS_CENTRAL_HOST", nil),
        port: ENV.fetch("REDIS_CENTRAL_PORT", nil),
        namespace: "rails-api-project",
      }
    ActionMailer::MailDeliveryJob.queue_as :default

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = false

    Rails.application.config.middleware.use ActionDispatch::Cookies
    Rails.application.config.middleware.use ActionDispatch::Session::CookieStore
  end
end
