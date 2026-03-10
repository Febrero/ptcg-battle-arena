module TicketTransactions
  class Spend < TicketTransaction
    field :game_mode_id, type: Integer
    field :spend_id, type: String # ! contains game_id (arenas), entry_id (survivals) or playoff_team_id ? (playoffs)
    field :sender, type: String # who spent the ticket

    validates :game_mode_id, :spend_id, :sender, presence: true
    validates :spend_id, uniqueness: {scope: :sender, case_sensitive: false}

    index({game_mode_id: 1}, {name: "game_mode_id_index", background: true})
    index({spend_id: 1}, {name: "spend_id_index", background: true})
    index({sender: 1}, {name: "sender_index", background: true})
  end
end
