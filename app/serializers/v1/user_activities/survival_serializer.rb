module V1
  module UserActivities
    class SurvivalSerializer < ActiveModel::Serializer
      attributes :game_mode_name,
        :game_mode_id,
        :levels_completed,
        :games,
        :created_at

      def game_mode_name
        object.survival_player.survival.name
      end

      def game_mode_id
        object.survival_player.survival.uid
      end

      def games
        object.games.map do |game|
          profiles = Rails.cache.fetch("UserActivities|SurvivalSerializer|GetProfilesByWalletAddresses|#{game.id}", expires_in: 5.minutes) do
            GetProfilesByWalletAddresses.call({filter: {wallet_addr: game.players_wallet_addresses}})
          end
          {
            game_id: game.game_id,
            tiebreaker_criteria: game.tiebreaker_criteria,
            players: ActiveModel::Serializer::CollectionSerializer.new(
              game.players, {serializer: UserActivities::GamePlayerSerializer, profiles: profiles}
            ),
            game_end_reason: game.game_end_reason
          }
        end
      end
    end
  end
end
