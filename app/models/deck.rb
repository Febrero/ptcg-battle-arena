class Deck
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  MAX_NAME_CHARACTER_COUNT = 20

  field :wallet_addr, type: String
  field :stars, type: Integer, default: 0
  field :name, type: String
  field :flag_status, type: Boolean, default: true
  field :nfts_count, type: Integer
  field :grey_cards_count, type: Integer
  field :nft_ids, type: Array, default: []
  field :video_ids, type: Array, default: []
  field :grey_card_ids, type: Array, default: []
  field :power, type: Integer

  validates :wallet_addr, :name, presence: true
  validates :name, uniqueness: {scope: :wallet_addr}
  validates :name, length: {maximum: MAX_NAME_CHARACTER_COUNT}

  validate :validate_wallet_limited_reached, on: :create
  validate :validate_maximum_deck_size
  validate :validate_maximum_repeated_nfts

  index({wallet_addr: 1}, {name: "wallet_addr_index", background: true})
  index({name: 1}, {name: "name_index", background: true})
  index({stars: 1}, {name: "stars_index", background: true})

  def nfts
    @nfts ||= begin
      Nft.search(nft_ids, wallet_addr.downcase)
    rescue
      []
    end
  end

  def validate_wallet_limited_reached
    config = Configs::GetConfig.call
    return unless Deck.where(wallet_addr: wallet_addr).count >= config[:decks][:rules][:max_wallet_decks_count]

    errors.add(:base, "Maximum number of decks reached")
  end

  def validate_maximum_deck_size
    config = Configs::GetConfig.call

    return unless nft_ids.size + grey_card_ids.size > config[:decks][:rules][:max_cards]

    errors.add(:base, "Maximum cards per deck reached")
  end

  def validate_maximum_repeated_nfts
    config = Configs::GetConfig.call

    nfts.each_with_object({}) do |item, obj|
      obj[item.video_id] ||= 0
      obj[item.video_id] += 1

      if obj[item.video_id] > config[:decks][:rules][:max_repeated_nfts]
        errors.add(:nft_ids, "Maximum repeated moments reached")

        break
      end
    end
  end
end
