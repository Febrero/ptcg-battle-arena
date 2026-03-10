require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = false

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  sidekiq_configs = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]["default"]
  config.cache_store = :redis_cache_store,
    sidekiq_configs.merge(
      {
        role: "master",
        expires_in: 1.hour,
        connect_timeout: 30, # Defaults to 20 seconds
        read_timeout: 2, # Defaults to 1 second
        write_timeout: 2, # Defaults to 1 second
        reconnect_attempts: 3 # Defaults to 0
      }
    )

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "realfevr_battle_arena_apis_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.app_base_url = "https://realfevr.com"
  # nft api base url
  config.nft_api_base_url = "https://nfts-api.realfevr.com"

  config.white_lists_api_base_url = "http://realfevr-whitelists"

  config.white_list_name = "battle-arena"

  config.external_api_key = ENV.fetch("EXTERNAL_API_KEY", "ptcg-internal-key")

  config.white_list_external_api_key = ENV.fetch("WHITE_LIST_EXTERNAL_API_KEY", "ptcg-whitelist-key")

  config.nfts_external_api_key = ENV.fetch("NFTS_EXTERNAL_API_KEY", "ptcg-nfts-key")

  config.mongodb_pw = ENV.fetch("MONGODB_PW", "")

  config.authentication_service = ENV.fetch("PTCG_WORLD_API_URL", "https://ptcg.world")

  config.auth_event_listener = "b319874dfd3446877be4203cd9be55af3c5b905dca98957de3dc089b5ac9061b6dccb07f78f92474c31ec1d55382ef96ef94b91c568d8f36517386e934568535"

  config.ticket_factory_contract_address = "0x1E9504095cf4b32059caab825545f9c7bA54b346"
  config.ticket_locker_and_distribution_contract_address = "0x5761540Ad00890458a44eb8Aecadc659268368Da"
  config.token_contract_address = "0x82030cdbd9e4b7c5bb0b811a61da6360d69449cc"
  config.opener_contract_address = "0x618dcd507d1dcedaed7df0df54728326fd33d22e"
  config.marketplace_contract_address = "0xdf8582ed8224bfc79af801674e6ce60c80f9f5fb"
  config.marketplace_v2_contract_address = "0xf61a66fe1c1b1cc53099b092a9250fec77e60718"
  config.dead_contract_address = "0x0000000000000000000000000000000000000000"
  config.ticket_offer_wallet_addr = "0x87d090728a5b835a283e8c8abB0A9C9fc0e73818"

  config.privacy_url = "https://organya.world/privacy-policy"
  config.terms_conditions_url = "https://organya.world/terms-conditions"
  config.store_url = "https://organya.world/shop/tickets"
  config.downloads_url = "https://organya.world/play-now"
  config.login_code_url = "https://organya.world/play-now"
  config.discord_url = "https://discord.gg/realfevr"
  config.realfevr_url = "https://nfts.realfevr.com/"
  config.realfevr_marketplace_url = "https://nfts.realfevr.com/marketplace"
  config.organya_url = "https://organya.world/"
  config.organya_marketplace_url = "https://organya.world/shop/marketplace"
  config.user_profile_url = nil
  config.help_url = "https://realfevr.gitbook.io/realfevr/organya-the-game/what-is-organya"

  config.leaderboards_service = "http://realfevr-leaderboards"

  config.asset_bundles = {
    bundles_url: "https://realfevr:SuperArena!@arena.realfevr.com/bundles",
    bundles_info_url: "https://realfevr:SuperArena!@arena.realfevr.com/bundles/bundles_info.json"
  }

  config.rpc_endpoint = "https://bsc-mainnet.nodereal.io/v1/fcdb87386f5146fab6cd6164b02224e1"
  config.free_rpc_endpoint = "https://bsc-dataseed.binance.org"

  config.sidekiqweb_basic_auth = {
    username: "realfevr", # Rails.application.credentials.sidekiqweb[:username],
    password: "R34lF3vr072021" # Rails.application.credentials.sidekiqweb[:password]
  }

  config.bridges_contracts = [
    # BSC contracts
    {contract_addr: "0xe73db0663d1e7c69111ea3a67e0b83963334f7e5", role: "erc721_bridge", chain_id: 56, origin_chain: true},
    # Arbitrum contracts
    {contract_addr: "0x7c675c6b1d39c9f764d150b387ac46dfd7b2ac27", role: "erc721_bridge", chain_id: 42161, origin_chain: false},
    {contract_addr: "0x8F0dF3b174eC595fE3d9b071d0DA95AF45f94edE", role: "erc721_base", chain_id: 42161, origin_chain: false}
  ]
  config.anonymous_avatar_url = "https://realfevr-production.s3.eu-central-1.amazonaws.com/nfts-markeplace/free_avatars/anonymous_avatar.png"

  config.marketplace_contracts = [
    # BSC contracts
    {contract_addr: "0xdf8582ed8224bfc79af801674e6ce60c80f9f5fb", role: "marketplace_v1", chain_id: 56},
    {contract_addr: "0xf61a66fe1c1b1cc53099b092a9250fec77e60718", role: "marketplace_v2", chain_id: 56},
    {contract_addr: "0xE756877A1c3E0be3A5e651cb41f13A156da6564A", role: "marketplace_v3", chain_id: 56},
    {contract_addr: "0x8B155Ca6226C6a3Accf8e4E93E198b5889a02216", role: "marketplace_v3", chain_id: 42161}
  ]
  config.mandrill_username = ENV.fetch("MANDRILL_USERNAME", "")
  config.mandrill_password = ENV.fetch("MANDRILL_PASSWORD", "")
  config.mandrill_mailer.default_url_options = {host: "organya.world"}

  config.server_sockets_url = "wss://battlearena-ws.realfevr.com:8443"
end
