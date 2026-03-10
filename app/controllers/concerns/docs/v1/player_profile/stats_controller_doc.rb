module Docs
  module V1
    module PlayerProfile
      module StatsControllerDoc
        extend Apipie::DSL::Concern

        ########## PARAM GROUPS START #########
        ########## PARAM GROUPS END ###########

        ########## ACTIONS DOC START ##########
        # api :GET, "/player_profile/stats/games", "User games stats (Authenticated)"
        def_param_group :player_profile_stats_controller_games do
          returns code: 200, desc: "Data" do
            property :seconds_played, Integer, desc: "Total seconds played"
            property :total_games, Integer, desc: "Total games"
            property :total_wins, Integer, desc: "Total wins"
            property :wins_average, Float, desc: "Games win average"
          end
          error code: 403, desc: "Forbidden"
        end

        # api :GET, "/player_profile/stats/decks", "User decks stats (Authenticated)"
        def_param_group :player_profile_stats_controller_decks do
          returns code: 200, desc: "Data" do
            property "1", Integer, desc: "Number of decks with 1 star"
            property "2", Integer, desc: "Number of decks with 2 stars"
            property "3", Integer, desc: "Number of decks with 3 stars"
            property "4", Integer, desc: "Number of decks with 4 stars"
            property "5", Integer, desc: "Number of decks with 5 stars"
          end
          error code: 403, desc: "Forbidden"
        end

        # api :GET, "/player_profile/stats/moments", "User moments stats (Authenticated)"
        def_param_group :player_profile_stats_controller_moments do
          returns code: 200, desc: "Data" do
            property "common", Integer, desc: "Number of common nfts"
            property "special", Integer, desc: "Number of special nfts"
            property "epic", Integer, desc: "Number of epic nfts"
            property "legendary", Integer, desc: "Number of legendary nfts"
            property "unique", Integer, desc: "Number of unique nfts"
            property "total", Integer, desc: "Number of nfts"
          end
          error code: 403, desc: "Forbidden"
        end
        ########## ACTIONS DOC END ############
      end
    end
  end
end
