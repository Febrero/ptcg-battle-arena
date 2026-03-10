module V1
  class GameSerializer < ActiveModel::Serializer
    attributes :game_id,
      :game_log_id,
      :game_mode_id,
      :match_type,
      :game_start_time,
      :game_end_time,
      :game_duration,
      :penalty_shootout,
      :golden_goal,
      :overtime,
      :round_number,
      :turn_number,
      :applied_xp_rules,
      :players_wallet_addresses,
      :winner,
      :any_player_resigned,
      :tiebreaker_criteria
  end
end
