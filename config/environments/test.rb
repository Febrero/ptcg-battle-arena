require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = true

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
  # nft api base url
  config.nft_api_base_url = "http://localhost:3100"

  config.white_lists_api_base_url = "http://localhost:3200"

  config.authentication_service = "http://localhost:3210"

  config.white_list_name = "battle-arena"

  config.external_api_key = "123"

  config.white_list_external_api_key = "123"

  config.nfts_external_api_key = "123"

  config.mongodb_pw = "123"

  config.auth_event_listener = "b319874dfd3446877be4203cd9be55af3c5b905dca98957de3dc089b5ac9061b6dccb07f78f92474c31ec1d55382ef96ef94b91c568d8f36517386e934568535"

  config.ticket_factory_contract_address = "0xCBEEDB880961503d85B4052f7F53Ea93f6d8dc2D"
  config.ticket_locker_and_distribution_contract_address = "0x4a30Da021b4D0Cc296C33e1F7572CdE1AF77013C"
  config.opener_contract_address = "0x3aA33C34b50be0024C9Deb99F6D7f4aE02444184"
  config.marketplace_contract_address = "0xEf89da436A3298D94601E021d7928F2f0D2F0725"
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

  config.leaderboards_service = "http://localhost:3230"

  config.asset_bundles = {
    bundles_url: "test_url",
    bundles_info_url: "test_url"
  }

  config.rpc_endpoint = "https://bsc-testnet.nodereal.io/v1/fc2ff4e4de9a4b6bb6be077b1f7bcdf5"
  config.free_rpc_endpoint = "https://data-seed-prebsc-1-s1.binance.org:8545"

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

  config.mandrill_username = ""
  config.mandrill_password = ""

  config.server_sockets_url = ""
end
