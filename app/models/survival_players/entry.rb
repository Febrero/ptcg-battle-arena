module SurvivalPlayers
  class Entry
    include Mongoid::Document
    include Mongoid::Timestamps

    field :levels_completed, type: Integer
    field :ticket_id, type: Integer
    field :ticket_amount, type: Integer, default: 1
    field :ticket_submitted_at, type: DateTime
    field :closed, type: Boolean
    field :closed_at, type: DateTime
    field :games_ids, type: Array, default: []

    embedded_in :survival_player, class_name: "SurvivalPlayer"

    def games
      Game.in(game_id: games_ids)
    end
  end
end
