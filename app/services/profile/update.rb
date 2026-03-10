module Profile
  class Update < ApplicationService
    def call(wallet_addr, params, auth)
      HTTParty.put(
        "#{Rails.application.config.nft_api_base_url}/profiles/#{wallet_addr}",
        headers: {
          Authorization: auth,
          "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
        }, body: {profile: params}
      )
    end
  end
end
