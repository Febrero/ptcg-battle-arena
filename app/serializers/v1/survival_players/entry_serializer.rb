module V1
  module SurvivalPlayers
    class EntrySerializer < ActiveModel::Serializer
      attributes :levels_completed, :ticket_id, :ticket_amount,
        :ticket_submitted_at, :closed, :closed_at, :games_ids, :level_prize

      def level_prize
        survival_stage = object.survival_player.survival.stages.where(level: object.levels_completed).first

        {prize_amount: survival_stage.try(:prize_amount) || 0,
         prize_type: survival_stage.try(:prize_type) || 0}
      end
    end
  end
end
