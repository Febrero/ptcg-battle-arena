class ProfileLeaderboardsInfoSearch
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def search
    response = HTTParty.get(
      "#{Rails.application.config.nft_api_base_url}/profiles/leaderboards_info",
      {
        query: params,
        headers: {
          "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
        }
      }
    )

    raise Net::HTTPRequestTimeout if response.code == 408
    raise Net::HTTPNotFound if response.code == 404
    raise StandardError if response.code != 200

    response.body
  rescue Errno::ECONNREFUSED
  end
end
