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
  config.force_ssl = false

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  config.cache_store = :redis_cache_store, {
    url: "redis://redis-staging:6379/3",
    role: "master",
    expires_in: 1.hour,
    connect_timeout: 30, # Defaults to 20 seconds
    read_timeout: 2, # Defaults to 1 second
    write_timeout: 2, # Defaults to 1 second
    reconnect_attempts: 3 # Defaults to 0
  }
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
  config.nft_api_base_url = "https://stg-nfts-api.realfevr.com"

  config.white_lists_api_base_url = "http://realfevr-whitelists-staging"

  config.leaderboards_service = "http://realfevr-leaderboards-staging"

  config.authentication_service = "http://realfevr-authentication-staging"

  config.white_list_name = "battle-arena"

  config.external_api_key = "arena_123"

  config.white_list_external_api_key = "white_list_123"

  config.nfts_external_api_key = "nfts_123"

  config.mongodb_pw = ENV.fetch("MONGODB_PW", nil)

  config.auth_event_listener = "b319874dfd3446877be4203cd9be55af3c5b905dca98957de3dc089b5ac9061b6dccb07f78f92474c31ec1d55382ef96ef94b91c568d8f36517386e934568535"

  config.ticket_factory_contract_address = "0x502e839B4EcBbc3932B78Ce0050E27786e0813A9"
  config.ticket_locker_and_distribution_contract_address = "0xf700AEE973D13d17B76AfE8426F44baCe1359957"
  config.opener_contract_address = "0x3aA33C34b50be0024C9Deb99F6D7f4aE02444184"
  config.marketplace_contract_address = "0x18b889a42cb81b30f67d0f6270dd85c1de7f76de"
  config.token_contract_address = "0xFe1787Ec9013Cd2A4e326fA3F329eaf610841a4F"
  config.marketplace_v2_contract_address = "0x0892359adD82c11a1c2818B28461Ea97E4910DEE"
  config.dead_contract_address = "0x0000000000000000000000000000000000000000"
  config.ticket_offer_wallet_addr = "0xC8ca63963202000d017842cF12f9F7c7290a6Abd"

  config.privacy_url = "https://staging.organya.world/privacy-policy"
  config.terms_conditions_url = "https://staging.organya.world/terms-conditions"
  config.store_url = "https://staging.organya.world/shop/tickets"
  config.downloads_url = "https://staging.organya.world/play-now"
  config.login_code_url = "https://staging.organya.world/play-now"
  config.discord_url = "https://discord.gg/realfevr"
  config.realfevr_url = "https://nfts.realfevr.com/"
  config.realfevr_marketplace_url = "https://nfts.realfevr.com/marketplace"
  config.organya_url = "https://staging.organya.world/"
  config.organya_marketplace_url = "https://staging.organya.world/shop/marketplace"
  config.user_profile_url = nil
  config.help_url = "https://realfevr.gitbook.io/realfevr/organya-the-game/what-is-organya"

  config.asset_bundles = {
    bundles_url: "https://realfevr:SuperC001@staging-arena.realfevr.com/bundles",
    bundles_info_url: "https://realfevr:SuperC001@staging-arena.realfevr.com/bundles/bundles_info.json"
  }

  config.rpc_endpoint = "https://bsc-testnet.nodereal.io/v1/fc2ff4e4de9a4b6bb6be077b1f7bcdf5"
  config.free_rpc_endpoint = "https://data-seed-prebsc-1-s1.binance.org:8545"

  config.sidekiqweb_basic_auth = {
    username: "realfevr", # Rails.application.credentials.sidekiqweb[:username],
    password: "R34lF3vr072021" # Rails.application.credentials.sidekiqweb[:password]
  }

  config.bridges_contracts = [
    # BSC Testnet contracts
    {contract_addr: "0x5cb442b298aa8365afe722bb82df6091aa16da65", role: "erc721_bridge", chain_id: 97, origin_chain: true},
    # Polygon Mumbai Testnet contracts
    {contract_addr: "0xdbBB9Fe8c5320c7FF18AE65eC743270a9A8C50a1", role: "erc721_base", chain_id: 80001, origin_chain: false},
    {contract_addr: "0x9815c692433bfea1d285bd9d0529e41b312b705a", role: "erc721_bridge", chain_id: 80001, origin_chain: false}
  ]

  config.marketplace_contracts = [
    # BSC Testnet contracts
    {contract_addr: "0x18b889a42cb81b30f67d0f6270dd85c1de7f76de", role: "marketplace_v1", chain_id: 97},
    {contract_addr: "0x0892359adD82c11a1c2818B28461Ea97E4910DEE", role: "marketplace_v2", chain_id: 97},
    {contract_addr: "0x13dC7b968cf2e6b38F7F532F0CCA4bF30F015Cf8", role: "marketplace_v3", chain_id: 97},
    # Polygon Mumbai Testnet contracts
    {contract_addr: "0x1ec814E3B4A15531fc8461568AcA7deFc05723Ba", role: "marketplace_v3", chain_id: 80001}
  ]

  config.mandrill_username = ENV.fetch("MANDRILL_USERNAME", "")
  config.mandrill_password = ENV.fetch("MANDRILL_PASSWORD", "")
  config.mandrill_mailer.default_url_options = {host: "staging.organya.world"}

  config.server_sockets_url = "ws://staging-arena-ws.realfevr.com:8080"
end
