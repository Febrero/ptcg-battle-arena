module Profile
  class ConfirmEmail < ApplicationService
    def call(params)
      HTTParty.put(
        "#{Rails.application.config.nft_api_base_url}/profiles/confirm_email",
        headers: {
          "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
        }, body: params
      )
    end
  end
end
