module Docs
  module V1
    module GamesControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :games_serializer_atributes do
        property :game_id, String, desc: "Game ID"
        property :game_log_id, String, desc: "Game log ID"
        property :arena_id, Integer, desc: "Arena ID"
        property :match_type, String, desc: "Match type"
        property :game_start_time, Integer, desc: "Game start time"
        property :game_end_time, Integer, desc: "Game end time"
        property :game_duration, Integer, desc: "Game duration"
        property :penalty_shootout, [true, false], desc: "Penalty shootout"
        property :golden_goal, [true, false], desc: "Golden goal"
        property :overtime, [true, false], desc: "Overtime"
        property :round_number, Integer, desc: "Round number"
        property :turn_number, Integer, desc: "Turn number"
        property :applied_xp_rules, Hash, desc: "Applied XP rules"
        property :players_wallet_addresses, Array, desc: "Players wallet addresses"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########

      # api :GET, "/games", "List of games (Authenticaded)"
      def_param_group :games_controller_index do
        returns code: 200, desc: "Game" do
          property :data, Array, desc: "Games" do
            param_group :games_serializer_atributes, GamesControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/games/:id", "Detail of a game"
      def_param_group :games_controller_show do
        param :id, Integer, desc: "ID of Game", required: true
        returns code: 200, desc: "Game info" do
          param_group :games_serializer_atributes, GamesControllerDoc
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/games/info", "Games totals info (Authenticated)"
      def_param_group :games_controller_info do
        returns code: 200, desc: "Games info" do
          property :data, Array, desc: "Array of game info " do
            property :name, String, desc: "Type of arena"
            property :count, Integer, desc: "Count of arena games"
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      ########## ACTIONS DOC END ############
    end
  end
end
