module V1
  module PlayerProfile
    class StatsController < ApplicationController
      include BasicAuth
      include Docs::V1::PlayerProfile::StatsControllerDoc

      prepend_before_action :authenticate_user!
      before_action :auth_frontend

      api :GET, "/player_profile/stats/games", "User games stats (Authenticated)"
      param_group :player_profile_stats_controller_games, Docs::V1::PlayerProfile::StatsControllerDoc
      def games
        render json: ::PlayerProfile::Stats::Games.call(@user_data["publicAddress"]), status: 200
      end

      api :GET, "/player_profile/stats/decks", "User decks stats (Authenticated)"
      param_group :player_profile_stats_controller_decks, Docs::V1::PlayerProfile::StatsControllerDoc
      def decks
        render json: ::PlayerProfile::Stats::Decks.call(@user_data["publicAddress"]), status: 200
      end

      api :GET, "/player_profile/stats/moments", "User moments stats (Authenticated)"
      param_group :player_profile_stats_controller_moments, Docs::V1::PlayerProfile::StatsControllerDoc
      def moments
        render json: ::PlayerProfile::Stats::Moments.call(@user_data["publicAddress"]), status: 200
      end
    end
  end
end
