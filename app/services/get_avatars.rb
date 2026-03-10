class GetAvatars < ApplicationService
  def call(user_auth)
    HTTParty.get(
      "#{Rails.application.config.nft_api_base_url}/avatars",
      headers: {
        Authorization: user_auth,
        "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
      }
    )
  end
end
