class EventTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :tx_hash, type: String
  field :name, type: String
  field :log_index, type: Integer
  field :tx_index, type: Integer
  field :block_number, type: Integer
  field :reverted, type: Boolean, default: false

  index({tx_hash: 1, log_index: 1}, {unique: true, name: "tx_hash_log_index_index", background: true})
  index({block_number: 1}, {name: "block_number_index", background: true})

  validates :tx_hash, uniqueness: {scope: :log_index, case_sensitive: false}
end
