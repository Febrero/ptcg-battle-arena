module Arenas
  class GeneratePrize < ApplicationService
    attr_accessor :arena, :game_player, :game_id

    def call(arena, game_player, game_id)
      Rails.logger.info "Generating prize for game\n\twallet_addr: #{game_player.wallet_addr}\n\tgame: #{game_player.game_id}"

      @arena = arena
      @game_player = game_player
      @game_id = game_id

      publish_to_rabbimtq_exchange(prize_message_for_arena_player)
    end

    private

    def publish_to_rabbimtq_exchange(msg)
      connection = Bunny.new(Rails.application.config.rabbitmq)

      connection.start

      channel = connection.create_channel
      exchange = channel.direct("battle_arena_games")

      exchange.publish(msg.to_json, routing_key: "prizes")

      connection.close
    end

    def prize_message_for_arena_player
      # prize amount persisted on game player doesn't include taxes...

      {game_id: game_id,
       ticket_id: game_player.ticket_id,
       ticket_amount: game_player.ticket_amount,
       erc20: arena.token["address"],
       erc20_name: arena.erc20_name,
       match_type: "Arena",
       game_mode: "Arena",
       game_mode_id: arena.uid,
       survival_levels_completed: nil,
       survival_max_level: nil,
       wallet_addr: game_player.wallet_addr,
       prize_awarded: game_player.winner,
       total_prize_amount: game_player.prize_amount,
       total_prize_winner_share: game_player.prize_amount * arena.winner_share,
       total_prize_realfevr_share: game_player.prize_amount * arena.rf_share,
       total_prize_burn_share: game_player.prize_amount * arena.burn_share}
    end
  end
end
