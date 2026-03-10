class PlayerProfile::Stats::Moments < ApplicationService
  def call(wallet_addr)
    response = nfts_summary(wallet_addr)

    response["nfts_per_rarity"]["total"] = response["nfts_count"]

    response["nfts_per_rarity"].transform_keys(&:downcase)
  end

  private

  def nfts_summary(wallet_addr)
    marketplace_api = Rails.application.config.realfevr_services[:marketplace]

    response = HTTParty.get(
      "#{marketplace_api[:service]}/nfts/summary/#{wallet_addr.downcase}",
      headers: {"X-RealFevr-I-Token": marketplace_api[:internal_api_key]}
    )

    case response.code
    when 200 then JSON.parse(response.body)
    when 408 then raise Net::HTTPRequestTimeout
    else; raise StandardError
    end
  end
end
