class GetLeaderboardsApi < ApplicationService
  def call(source, time_range, query_params)
    lb_base_url = Rails.application.config.leaderboards_service
    HTTParty.get("#{lb_base_url}/leaderboards/#{source}/#{time_range}", {query: query_params})
  rescue Errno::ECONNREFUSED
  end

  def request_nft_api(url_path, options = {})
    HTTParty.get(
      "#{Rails.application.config.nft_api_base_url}#{url_path}",
      {
        headers: {
          "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
        }
      }.merge(options)
    )
  end

  def profile_info(query_params)
    request_nft_api("/profiles/leaderboards_info", {query: query_params})
  end
end
