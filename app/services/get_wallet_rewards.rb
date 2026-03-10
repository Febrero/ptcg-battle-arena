class GetWalletRewards < ApplicationService
  def call(wallet_addr, auth)
    HTTParty.get(
      "#{Rails.application.config.nft_api_base_url}/rewards/wallet?grouped=true",
      headers: {
        Authorization: auth,
        "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
      }
    )
  end
end
