class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :bc_ticket_id, type: Integer
  field :name, type: String
  field :description, type: String
  field :erc20_name, type: String
  field :base_price, type: Float
  field :start_date, type: Time
  field :expiration_date, type: Time
  field :sale_expiration_date, type: Time
  field :available_quantities, type: Array
  field :image_url, type: String
  field :entry_image_url, type: String
  field :fees, type: Array
  field :discount, type: Array
  field :tickets_num_discount, type: Array
  field :active, type: Boolean
  field :position, type: Integer
  field :ticket_factory_contract_address, type: String
  field :ticket_locker_and_distribution_contract_address, type: String
  field :zero_fees, type: Boolean, default: false
  field :promo, type: Boolean, default: false
  field :game_mode, type: String # arena|survival|playoff

  validates :name, presence: true
  validates :description, presence: true
  validates :base_price, presence: true
  validates :expiration_date, presence: true
  validates :sale_expiration_date, presence: true
  validates :available_quantities, presence: true
  validates :game_mode, presence: true
  validates :game_mode, inclusion: %w[arena survival playoff]

  validates :bc_ticket_id, presence: true, uniqueness: {scope: [:ticket_factory_contract_address]}

  index({bc_ticket_id: 1, ticket_factory_contract_address: 1}, {unique: true, name: "bc_ticket_id_ticket_factory_contract_address_index", background: true})
  index({position: 1}, {name: "position_index", background: true})
  index({active: 1}, {name: "active_index", background: true})
  index({game_mode: 1}, {name: "game_mode_index", background: true})

  has_many :ticket_balances
  has_many :ticket_bundles
  has_many :ticket_offers

  def token
    Rails.cache.fetch("Ticket::FetchToken::#{erc20_name}", expires_in: 5.minutes) do
      FetchToken.call(erc20_name)["data"]["attributes"]
    rescue
      {}
    end
  end

  def is_unique_zero_fees
    zero_fees && Ticket.where(zero_fees: false, ticket_factory_contract_address: ticket_factory_contract_address, ticket_locker_and_distribution_contract_address: ticket_locker_and_distribution_contract_address).count == 0
  end

  def self.by_game_mode
    pipeline = [
      {
        "$match": {
          active: true # Filter documents where 'active' is true
        }
      },
      {
        "$group": {
          _id: "$game_mode",
          tickets: {
            "$push": "$$ROOT" # Push the entire document into the 'tickets' array
          }
        }
      },
      {
        "$unwind": "$tickets" # Unwind the 'tickets' array to separate the documents
      },
      {
        "$sort": {
          "tickets.game_mode": 1,
          "tickets.position": 1 # Sort by 'contract_addr' and 'position' fields in ascending order
        }
      },
      {
        "$group": {
          _id: "$_id",
          tickets: {
            "$push": "$tickets" # Re-group the documents by 'contract_addr'
          }
        }
      }
    ]

    # Run the aggregation pipeline
    result = collection.aggregate(pipeline)
    # return hash with modes as keys
    result.each_with_object({}) do |elm, acc|
      acc[elm["_id"]] = elm["tickets"].map { |t| instantiate(t) }
    end
  end
end
