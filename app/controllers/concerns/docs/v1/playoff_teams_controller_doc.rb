module Docs
  module V1
    module PlayoffTeamsControllerDoc
      extend Apipie::DSL::Concern

      ########## HELPERS #########
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
      def_param_group :playoff_teams_controller_index do
        returns code: 200, desc: "Playoffs" do
          property :data, Array, desc: "Array of playoffs teams" do
            property :id, String, desc: "ID of the playoffs team"
            property :type, String, desc: "Type of the playoffs team"
            property :attributes, Hash, desc: "Playoffs team attributes" do
              property :wallet_addr, String, desc: "Wallet address of the team"
              property :name, String, desc: "Name of the team"
              property :current_bracket_id, String, desc: "ID of the current bracket"
              # Add more properties here if needed
            end
          end
          param_group :playoff_pagination_attributes, PlayoffTeamsControllerDoc
        end
        error code: 403, desc: "Forbidden"
      end

      def_param_group :playoff_teams_controller_create do
        param :data, Hash, required: true, desc: "Data object" do
          param :attributes, Hash, required: true, desc: "Ticket attributes" do
            param :playoff_id, Integer, desc: "ID of the playoff"
            param :ticket_id, String, desc: "ID of the ticket"
          end
        end
        returns code: 200, desc: "Success" do
          property :data, Hash, desc: "Playoffs team data" do
            property :id, String, desc: "ID of the playoffs team"
            property :type, String, desc: "Type of the playoffs team"
            property :attributes, Hash, desc: "Playoffs team attributes" do
              property :wallet_addr, String, desc: "Wallet address of the team"
              property :name, String, desc: "Name of the team"
              property :current_bracket_id, String, desc: "ID of the current bracket"
              # Add more properties here if needed
            end
          end
        end
        error code: 403, desc: "Forbidden"
      end

      def_param_group :playoff_teams_controller_show do
        returns code: 200, desc: "Playoffs Team" do
          property :data, Hash, desc: "Playoffs team data" do
            property :id, String, desc: "ID of the playoffs team"
            property :type, String, desc: "Type of the playoffs team"
            property :attributes, Hash, desc: "Playoffs team attributes" do
              property :wallet_addr, String, desc: "Wallet address of the team"
              property :name, String, desc: "Name of the team"
              property :current_bracket_id, String, desc: "ID of the current bracket"
              # Add more properties here if needed
            end
          end
        end
        error code: 403, desc: "Forbidden"
      end
    end
  end
end
