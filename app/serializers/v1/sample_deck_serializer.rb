module V1
  class SampleDeckSerializer < ActiveModel::Serializer
    attributes :type,
      :stars,
      :serial_number,
      :flag_status,
      :nfts_count,
      :grey_cards_count,
      :video_ids,
      :grey_card_ids,
      :power
  end
end
