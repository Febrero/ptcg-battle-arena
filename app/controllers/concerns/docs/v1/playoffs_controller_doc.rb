module Docs
  module V1
    module PlayoffsControllerDoc
      extend Apipie::DSL::Concern

      ########## HELPERS #########
      def_param_group :playoff_index_serializer_attributes do
        property :uid, Integer, desc: "UID of the playoff"
        property :name, String, desc: "Name of the playoff"
        property :total_prize_pool, Float, desc: "Total prize pool of the playoff"
        property :prize_pool_winner_share, Float, desc: "Winner share of the prize pool"
        property :prize_pool_realfevr_share, Float, desc: "RealFevr share of the prize pool"
        property :compatible_ticket_ids, Array, of: String, desc: "Compatible ticket IDs"
        property :active, :boolean, desc: "Indicates if the playoff is active"
        property :image_url, String, desc: "URL of the image"
        property :skewed_image_url, String, desc: "URL of the skewed image"
        property :background_image_url, String, desc: "URL of the background image"
        property :erc20, String, desc: "ERC20 token address"
        property :erc20_name, String, desc: "ERC20 token name"
        property :card_image_url, String, desc: "URL of the card image"
        property :layout_colors, String, desc: "Layout colors"
        property :ticket_factory_contract_address, String, desc: "Address of the ticket factory contract"
        property :ticket_locker_and_distribution_contract_address, String, desc: "Address of the ticket locker and distribution contract"
        property :game_mode, String, desc: "Game mode of the playoff"
        property :min_teams, Integer, desc: "Minimum number of teams"
        property :max_teams, Integer, desc: "Maximum number of teams"
        property :timeframes, Hash, desc: "Timeframe information" do
          property :registration_starts, String, desc: "Start time of registration"
          property :registration_ends, String, desc: "End time of registration"
          property :end_dates_per_round, Array, of: String, desc: "End time of each round"
          property :end_date, String, desc: "Overall end time of the playoff"
        end
        property :state, String, desc: "State of the playoff"
        property :current_round, Integer, desc: "Current round number"
        property :winner_team_id, String, desc: "ID of the winner team"
        property :min_deck_tier, Integer, desc: "Minimum deck tier"
        property :max_deck_tier, Integer, desc: "Maximum deck tier"
        property :prize_distribution, Array, desc: "Prize distribution details" do
          property :ranking_start, Integer, desc: "Starting rank for the prize"
          property :ranking_end, Integer, desc: "Ending rank for the prize"
          property :prize, Float, desc: "Prize amount"
          property :rounds_completed, Integer, desc: "Number of completed rounds for the prize"
        end
      end

      def_param_group :playoff_brackets_info_serializer_attributes do
        property :brackets_info, Hash, desc: "Brackets information" do
          property :previous_brackets, Array, of: Integer, desc: "IDs of previous brackets"
          property :teams_ids, Array, of: String, desc: "IDs of teams"
          property :current_bracket, Integer, desc: "ID of the current bracket"
          property :round, Integer, desc: "Current round number"
          property :next_bracket, Integer, desc: "ID of the next bracket"
          property :next_bracket_id, String, desc: "ID of the next bracket"
          property :winner_team_id, String, desc: "ID of the winner team"
          property :winner_selected_by_system, :boolean, desc: "Indicates if the winner team was selected by the system"
          property :playoff_id, Integer, desc: "ID of the playoff"
          property :game_id, String, desc: "ID of the game"
          property :id, String, desc: "ID of the bracket"
          property :teams_info, Array, of: Hash, desc: "Information about the teams" do
            property :wallet_addr, String, desc: "Wallet address of the team"
            property :name, String, desc: "Name of the team"
          end
          property :child_brackets, Array, of: Hash, desc: "Child brackets" do
            # ... Define child brackets properties here (same structure as brackets_info)
          end
        end
      end

      def_param_group :playoff_prize_config_serializer_attributes do
        property :prize_percentage_per_round, Hash, desc: "Prize percentage per round" do
          property "round_number", Integer, desc: "Percentage for round X"
        end
      end

      def_param_group :playoff_pagination_attributes do
        property :meta, Hash, desc: "Metadata" do
          property :current_page, Integer, desc: "Current page number"
          property :next_page, Integer, desc: "Next page number"
          property :prev_page, Integer, desc: "Previous page number"
          property :total_pages, Integer, desc: "Total number of pages"
          property :total_count, Integer, desc: "Total count of playoffs"
        end
      end

      ########## ACTIONS DOC START ##########
      # api :GET, "/playoffs", "List of Playoffs (Authenticaded)"
      def_param_group :playoffs_controller_index do
        returns code: 200, desc: "Playoffs" do
          property :data, Array, desc: "Playoffs" do
            property :id, String, desc: "ID of the playoff"
            property :type, String, desc: "Type of the playoff"
            property :attributes, Hash, desc: "Playoff attributes" do
              param_group :playoff_index_serializer_attributes, PlayoffsControllerDoc
            end
          end
          param_group :playoff_pagination_attributes, PlayoffsControllerDoc
        end
        error code: 403, desc: "Forbidden"
      end

      def_param_group :playoffs_controller_show do
        returns code: 200, desc: "Playoffs" do
          property :data, Hash, desc: "Playoffs" do
            property :id, String, desc: "ID of the playoff"
            property :type, String, desc: "Type of the playoff"
            property :attributes, Hash, desc: "Playoff attributes" do
              param_group :playoff_index_serializer_attributes, PlayoffsControllerDoc
              param_group :playoff_brackets_info_serializer_attributes, PlayoffsControllerDoc
            end
          end
        end
        error code: 403, desc: "Forbidden"
      end

      def_param_group :playoffs_controller_show_prize_config do
        returns code: 200, desc: "Playoffs" do
          property :data, Hash, desc: "Playoffs" do
            property :id, String, desc: "ID of the playoff"
            property :type, String, desc: "Type of the playoff"
            property :attributes, Hash, desc: "Playoff attributes" do
              param_group :playoff_index_serializer_attributes, PlayoffsControllerDoc
              param_group :playoff_prize_config_serializer_attributes, PlayoffsControllerDoc
            end
          end
        end
        error code: 403, desc: "Forbidden"
      end

      def_param_group :playoffs_controller_current_bracket do
        returns code: 200, desc: "Playoffs" do
          property :data, Hash, desc: "Playoffs bracket data" do
            property :id, String, desc: "ID of the playoffs bracket"
            property :type, String, desc: "Type of the playoffs bracket"
            property :attributes, Hash, desc: "Playoffs bracket attributes" do
              property :current_bracket, Integer, desc: "ID of the current bracket"
              property :next_bracket, Integer, desc: "ID of the next bracket"
              property :round, Integer, desc: "Current round number"
              property :teams_ids, Array, of: String, desc: "IDs of the teams"
            end
          end
        end
        error code: 403, desc: "Forbidden"
      end
    end
  end
end
