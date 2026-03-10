class GamePlayer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :wallet_addr, type: String
  field :deck_id, type: String
  field :ticket_id, type: String
  field :ticket_amount, type: Integer
  field :outcome, type: String
  field :goals_scored, type: Integer
  field :goals_conceded, type: Integer
  field :killcount, type: Integer
  field :hattricks, type: Integer
  field :saves, type: Integer
  field :deck_power, type: Integer
  field :deck_level, type: Integer
  field :rank_before_game, type: Integer
  field :underdog, type: Boolean
  field :winner, type: Boolean
  field :resigned, type: Boolean
  field :prize_amount, type: Float, default: 0
  field :prize_type, type: String

  belongs_to :game

  index({game_id: 1}, {name: "game_id_index", background: true})
  index({wallet_addr: 1}, {name: "wallet_addr_index", background: true})
end
