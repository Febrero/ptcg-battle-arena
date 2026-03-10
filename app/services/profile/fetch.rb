module Profile
  class Fetch < ApplicationService
    def call(wallet_addr, auth, default_view = nil)
      response = HTTParty.get(
        "#{Rails.application.config.nft_api_base_url}/profiles/#{wallet_addr}#{default_view ? "?default_view=#{default_view}" : ""}",
        headers: {
          Authorization: auth,
          "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
        }
      )

      profile = begin
        parsed_response = JSON.parse(response.body)
        tutorial_status = TutorialProgresses::GetUserProgress.call(wallet_addr)
        parsed_response["data"]["attributes"]["tutorial_status"] = tutorial_status
        parsed_response
      rescue
        nil
      end

      [profile, response.code]
    end
  end
end
