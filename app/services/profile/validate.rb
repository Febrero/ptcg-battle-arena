module Profile
  class Validate < ApplicationService
    def call(params, auth)
      HTTParty.put(
        "#{Rails.application.config.nft_api_base_url}/profiles/validate",
        headers: {
          Authorization: auth,
          "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
        }, body: {profile: params}
      )
    end
  end
end
