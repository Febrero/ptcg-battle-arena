module Docs
  module V1
    module SeasonsControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :season_serializer_attributes do
        property :uid, Integer, desc: "Season unique identifier"
        property :name, String, desc: "Season name"
        property :start_date, DateTime, desc: "when season started"
        property :end_date, DateTime, desc: "when season ends"
        property :active, [true, false], desc: "is season active or not"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/seasons", "List of season (Authenticaded)"
      def_param_group :seasons_controller_index do
        returns code: 200, desc: "Season" do
          property :data, Array, desc: "Season" do
            param_group :season_serializer_attributes, SeasonsControllerDoc
          end
        end
        error code: 403, desc: "Forbidden"
      end

      # api :GET, "/seasons/:id", "Season details (Authenticaded)"
      def_param_group :seasons_controller_show do
        returns code: 200, desc: "Season" do
          param_group :season_serializer_attributes, SeasonsControllerDoc
        end
        error code: 403, desc: "Forbidden"
      end

      # api :POST, "/seasons", "Create season (Authenticaded)"s
      def_param_group :seasons_controller_create do
        returns code: 200, desc: "Season" do
          param_group :season_serializer_attributes, SeasonsControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :PUT, "/arenas/:id", "Update season (Authenticaded)"
      def_param_group :seasons_controller_update do
        returns code: 200, desc: "Arena" do
          param_group :season_serializer_attributes, SeasonsControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :DELETE, "/arenas/:id", "Delete Season (Authenticaded)"
      def_param_group :seasons_controller_destroy do
        returns code: 204, desc: "No content"
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
