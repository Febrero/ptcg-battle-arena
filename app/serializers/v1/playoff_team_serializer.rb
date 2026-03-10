module V1
  class PlayoffTeamSerializer < ActiveModel::Serializer
    attributes :wallet_addr, :name, :current_bracket_id, :xp_level, :still_in_playoff, :ended_at, :prize_amount, :last_round, :registered_time

    def registered_time
      object.created_at.to_i
    end

    def last_round
      if object.last_round == ::Playoffs::Team::LAST_ROUND_WHEN_IN_PLAYOFF
        return nil
      end
      object.last_round
    end
  end
end
