module V1
  module UserActivities
    class GameSerializer < ActiveModel::Serializer
      attributes :game_mode_name,
        :game_mode_id,
        :tiebreaker_criteria,
        :players,
        :created_at,
        :game_end_reason

      def game_mode_name
        object.game_mode.name
      end

      def game_mode_id
        object.game_mode.uid
      end

      def players
        profiles = Rails.cache.fetch("UserActivities|GameSerializer|GetProfilesByWalletAddresses|#{object.game_id}", expires_in: 5.minutes) do
          GetProfilesByWalletAddresses.call({filter: {wallet_addr: object.players_wallet_addresses&.join(",")}})
        end

        ActiveModel::Serializer::CollectionSerializer.new(
          object.players,
          {serializer: UserActivities::GamePlayerSerializer, profiles: profiles}
        )
      end
    end
  end
end
