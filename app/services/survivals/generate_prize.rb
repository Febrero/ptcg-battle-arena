module Survivals
  class GeneratePrize < ApplicationService
    attr_accessor :survival, :survival_player, :game_id

    def call survival, survival_player, game_id = nil
      Rails.logger.info "Generating prize for survival player\n\twallet_addr: #{survival_player.wallet_addr}\n\tsurvival: #{survival_player.survival_id}"

      @game_id = game_id
      @survival = survival
      @survival_player = survival_player

      publish_to_rabbimtq_exchange(prize_message_for_survival_player)
    end

    private

    def publish_to_rabbimtq_exchange msg
      connection = Bunny.new(Rails.application.config.rabbitmq)

      connection.start

      channel = connection.create_channel
      exchange = channel.direct("battle_arena_games")

      exchange.publish(msg.to_json, routing_key: "prizes")

      connection.close
    end

    def prize_message_for_survival_player
      current_entry = survival_player.current_entry # TODO should be last_entry
      stage_prize_amount = survival.stages.where(level: current_entry.levels_completed).first.try(:prize_amount) || 0

      {game_id: game_id,
       ticket_id: current_entry.ticket_id,
       ticket_amount: current_entry.ticket_amount,
       erc20: survival.token["address"],
       erc20_name: survival.erc20_name,
       match_type: "Survival",
       game_mode: "Survival",
       game_mode_id: survival.uid,
       survival_levels_completed: current_entry.levels_completed,
       survival_max_level: survival.levels_count,
       wallet_addr: survival_player.wallet_addr,
       prize_awarded: (current_entry.levels_completed > 0),
       total_prize_amount: stage_prize_amount,
       total_prize_winner_share: stage_prize_amount * survival.winner_share,
       total_prize_realfevr_share: stage_prize_amount * survival.rf_share,
       total_prize_burn_share: stage_prize_amount * survival.burn_share}
    end
  end
end
