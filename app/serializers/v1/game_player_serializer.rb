module V1
  class GamePlayerSerializer < ActiveModel::Serializer
    attributes :wallet_addr,
      :deck_id,
      :ticket_id,
      :ticket_amount,
      :outcome,
      :goals_scored,
      :goals_conceded,
      :killcount,
      :hattricks,
      :saves,
      :deck_power,
      :deck_level,
      :rank_before_game,
      :underdog,
      :winner,
      :resigned
  end
end
