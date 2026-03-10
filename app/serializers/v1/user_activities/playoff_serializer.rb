module V1
  module UserActivities
    class PlayoffSerializer < ActiveModel::Serializer
      attributes :game_mode_name,
        :game_mode_id,
        :games,
        :rounds_winner,
        :start_date,
        :has_prize,
        :position,
        :total_rounds

      def total_rounds
        object.total_rounds
      end

      def has_prize
        instance_options[:team].has_prize?
      end

      def position
        instance_options[:team].position
      end

      def game_mode_name
        object.name
      end

      def game_mode_id
        object.uid
      end

      def rounds_winner
        instance_options[:team].total_wins
      end

      def start_date
        object.timeframes[:start_date]
      end

      def games
        instance_options[:team].brackets.map do |bracket|
          if bracket.game_id.nil?

            game_players = [
              GamePlayer.new(wallet_addr: instance_options[:team].wallet_addr, goals_scored: 0, outcome: "win")
            ]

            game_info(bracket.id, nil, instance_options[:team].wallet_addr, game_players, "bye", bracket.round, true, "bye")

          else
            game = Game.find_by(game_id: bracket.game_id)
            is_winner = (bracket.winner_team_id == instance_options[:team].id.to_s)

            game_info(bracket.id, game.id.to_s, game.players_wallet_addresses&.join(","), game.players, game.tiebreaker_criteria, bracket.round, is_winner, game.game_end_reason)
          end
        end
      end

      private

      def game_info bracket_id, game_id, profile_wallets, game_players, tiebreaker_criteria, current_round, is_winner, game_end_reason
        profiles = Rails.cache.fetch("UserActivities|PlayoffSerializer|GetProfilesByWalletAddresses|#{bracket_id}", expires_in: 5.minutes) do
          GetProfilesByWalletAddresses.call({filter: {wallet_addr: profile_wallets}})
        end

        {
          game_id: game_id,
          tiebreaker_criteria: tiebreaker_criteria,
          players: ActiveModel::Serializer::CollectionSerializer.new(
            game_players, {serializer: UserActivities::GamePlayerSerializer, profiles: profiles}
          ),
          current_round: current_round,
          winner: is_winner,
          game_end_reason: game_end_reason
        }
      end
    end
  end
end
