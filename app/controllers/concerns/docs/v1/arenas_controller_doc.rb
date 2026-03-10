module Docs
  module V1
    module ArenasControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :arena_serializer_attributes do
        property :uid, Integer, desc: "Arena's unique identifier"
        property :name, String, desc: "Arena name"
        property :total_prize_pool, Integer, desc: "Total prize pool"
        property :prize_pool_winner_share, Integer, desc: "Prize pool winner share"
        property :prize_pool_realfevr_share, Integer, desc: "Prize pool realfevr share"
        property :compatible_ticket_ids, Array, desc: "Compatible ticket ids list"
        property :erc20, Array, desc: "Arena ERC20 token address"
        property :image_url, String, desc: "Arena image url"
        property :card_image_url, String, desc: "Arena card image url"
        property :background_image_url, String, desc: "Arena background image url"
        property :active, [true, false], desc: "Whether this arena is active or not"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/arenas", "List of arenas (Authenticaded)"
      def_param_group :arenas_controller_index do
        returns code: 200, desc: "Arena" do
          property :data, Array, desc: "Arena" do
            param_group :arena_serializer_attributes, ArenasControllerDoc
          end
        end
        error code: 403, desc: "Forbidden"
      end

      # api :GET, "/arenas/id", "Arena details (Authenticaded)"
      def_param_group :arenas_controller_show do
        returns code: 200, desc: "Arena" do
          param_group :arena_serializer_attributes, ArenasControllerDoc
        end
        error code: 403, desc: "Forbidden"
      end

      # api :POST, "/arenas", "Create arena (Authenticaded)"s
      def_param_group :arenas_controller_create do
        returns code: 200, desc: "Arena" do
          param_group :arena_serializer_attributes, ArenasControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :PUT, "/arenas/:id", "Update arena (Authenticaded)"
      def_param_group :arenas_controller_update do
        returns code: 200, desc: "Arena" do
          param_group :arena_serializer_attributes, ArenasControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :DELETE, "/arenas/:id", "Delete arena (Authenticaded)"
      def_param_group :arenas_controller_destroy do
        returns code: 204, desc: "No content"
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
