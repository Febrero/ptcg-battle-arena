module TicketTransactions
  class BuyTicket < TicketTransaction
    field :tx_hash, type: String
    field :log_index, type: Integer
    field :block_number, type: Integer
    field :receiver, type: String # who bought the ticket

    validates :tx_hash, :log_index, :block_number, :receiver, presence: true
    validates :tx_hash, uniqueness: {scope: :log_index, case_sensitive: false}

    index({tx_hash: 1, log_index: 1}, {name: "tx_hash_log_index_index", unique: true, sparse: true, background: true})
    index({tx_hash: 1}, {name: "tx_hash_index", background: true})
    index({log_index: 1}, {name: "log_index_index", background: true})
    index({block_number: 1}, {name: "block_number_index", background: true})
    index({receiver: 1}, {name: "receiver_index", background: true})
  end
end
