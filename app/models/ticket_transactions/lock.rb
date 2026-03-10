module TicketTransactions
  class Lock < TicketTransaction
    field :tx_hash, type: String
    field :log_index, type: Integer
    field :block_number, type: Integer
    field :sender, type: String # who locked the ticket
    field :ticket_locker_and_distribution_contract_address, type: String

    validates :tx_hash, :log_index, :block_number, :sender, :ticket_locker_and_distribution_contract_address, presence: true
    validates :tx_hash, uniqueness: {scope: :log_index, case_sensitive: false}

    index({tx_hash: 1, log_index: 1}, {name: "tx_hash_log_index_index", unique: true, sparse: true, background: true})
    index({tx_hash: 1}, {name: "tx_hash_index", background: true})
    index({log_index: 1}, {name: "log_index_index", background: true})
    index({block_number: 1}, {name: "block_number_index", background: true})
    index({sender: 1}, {name: "sender_index", background: true})
    index({ticket_locker_and_distribution_contract_address: 1},
      {name: "ticket_locker_and_distribution_contract_address_index", background: true})
  end
end
