class CardOffer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :wallet_addr, type: String
  field :quantity, type: Integer
  field :card_type, type: String # grey_card or other...
  field :offer_detail, type: Hash
  field :reward_key, type: String
  field :source, type: String
  field :delivered, type: Boolean, default: false
  field :delivered_at, type: Time

  validates :wallet_addr, :quantity, :card_type, :offer_detail, :source, presence: true

  index({wallet_addr: 1}, {name: "wallet_addr_index", background: true})
  index({reward_key: 1}, {name: "reward_key_index", background: true})
  index({card_type: 1}, {name: "card_type_index", background: true})
  index({source: 1}, {name: "source_index", background: true})
end
