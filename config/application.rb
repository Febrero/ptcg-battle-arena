require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RealfevrBattleArenaApis
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # This also configures session_options for use below
    config.session_store :cookie_store, key: "_interslice_session"

    # Required for all session management (regardless of session_store)
    config.middleware.use ActionDispatch::Cookies

    config.middleware.use config.session_store, config.session_options

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"

        resource "*",
          headers: :any,
          methods: :any
      end
    end

    config.blacklisted_terms = YAML.load_file("#{Rails.application.root}/config/blacklisted_terms.yml").try(:[], "blacklisted") || []

    config.rabbitmq = {
      hostname: Rails.application.credentials.dig(:rabbitmq, :hostname),
      user: Rails.application.credentials.dig(:rabbitmq, :user),
      vhost: Rails.application.credentials.dig(:rabbitmq, :vhost),
      password: Rails.application.credentials.dig(:rabbitmq, :password)
    }

    services_config = config_for(:services)

    config.internal_api_key = services_config[:internal_api_key]
    config.realfevr_services = services_config[:realfevr_services].with_indifferent_access

    config.marketplace_videos_cache_key = "Marketplace::Videos::All"
    config.rewards_history_images = YAML.load_file("config/rewards_history_images.yml").with_indifferent_access
  end
end
