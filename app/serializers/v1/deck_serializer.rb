module V1
  class DeckSerializer < ActiveModel::Serializer
    attributes :name,
      :wallet_addr,
      :flag_status,
      :nfts_count,
      :grey_cards_count,
      :power,
      :stars
  end
end
