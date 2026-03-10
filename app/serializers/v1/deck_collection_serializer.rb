module V1
  class DeckCollectionSerializer < ActiveModel::Serializer
    attributes :id, :name, :flag_status, :nft_ids, :nfts, :grey_cards, :nfts_count, :grey_card_ids, :grey_cards_count, :power, :stars, :wallet_addr

    def id
      object.id.to_s
    end

    def nfts
      ActiveModel::Serializer::CollectionSerializer.new(object.nfts, {serializer: DeckNftSerializer, nfts_power: nfts_power})
    end

    def grey_cards
      grey_c = GreyCard.in(uid: object.grey_card_ids).to_a
      grey_nfts_power = grey_c.each_with_object({}) do |elm, acc|
        acc[elm.uid] = elm.power
      end
      ActiveModel::Serializer::CollectionSerializer.new(object.grey_card_ids.map { |uid| grey_c.detect { |c| c.uid == uid } }, {serializer: DeckGreyCardSerializer, nfts_power: grey_nfts_power})
    end

    private

    def nfts_power
      videos = FetchVideos.call({options: {disable_pagination: true}})["data"]

      @nfts_power ||= videos.each_with_object({}) do |elm, acc|
        acc[elm["attributes"]["uid"]] = elm["attributes"]["power"]
      end
    end
  end
end
