class Nft < ActiveResource::Base
  self.site = URI.join Rails.application.config.realfevr_services[:marketplace][:service]
  headers["X-RealFevr-Token"] = Rails.application.config.realfevr_services[:marketplace][:external_api_key]
  headers["X-RealFevr-I-Token"] = Rails.application.config.realfevr_services[:marketplace][:internal_api_key]
  self.element_name = "nft"
  self.primary_key = "uid"
  self.format = CustomJsonApiFormat
  self.collection_parser = PaginatedCollection

  POSITION_MIDFIELDER = "Midfielder"
  POSITION_GOALKEEPER = "Goalkeeper"
  POSITION_DEFENDER = "Defender"
  POSITION_FORWARD = "Forward"

  def self.search(nft_ids, wallet_addr)
    where(
      uid: nft_ids.join(","),
      wallet_addr: wallet_addr,
      per_page: 96,
      order: "price_asc"
    )
  end

  def self.find_by(params_hash)
    where(params_hash).first
  end
end
