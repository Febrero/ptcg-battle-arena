module Docs
  module V1
    module QuestsControllerDoc
      extend Apipie::DSL::Concern

      def_param_group :prizes_attributes do
        param :type, String, desc: "The type of the prize"
        param :amount, Integer, desc: "The amount of the prize"
      end

      def_param_group :day_prizes do
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Data" do
            property :id, String, desc: "ID"
            property :type, String, desc: "Type"
            property :attributes, Hash, desc: "Attributes" do
              param :uid, Integer, desc: "The uid of quest"
              param :type, String, desc: "The name of quest"
              param :active, [true, false], desc: "Field so set quest active or not"
              param :stages, Array do
                param :level, Integer, desc: "The day number"
                param :prizes, Array, desc: "An array of prizes" do
                  param :type, String, desc: "The type of the prize"
                  param :amount, Integer, desc: "The amount of the prize"
                  param :subtype, String, desc: "Subtype of prize (comon, lisbon, etc)"
                end
              end
            end
          end
        end
      end

      def_param_group :current_streak do
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Data" do
            property :id, String, desc: "ID"
            property :type, String, desc: "Type"
            property :attributes, Hash, desc: "Attributes" do
              param :sequence, Integer, desc: "The day number"
              param :last_game_played, DateTime, desc: "The datetime of last game"
              param :quest_uid, Integer, desc: "The Quest Identifier"
            end
          end
        end
      end

      ########## PARAM GROUPS START #########
      def_param_group :quest_serializer_atributes do
        property :uid, String, desc: "Quest Id"
        property :type, String, desc: "Name os quest"
        property :config, Hash, desc: "Prizes configurations by days"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########

      # api :GET, "/quests", "List of quests (Authenticaded)"
      def_param_group :quests_controller_index do
        returns code: 200, desc: "Quest" do
          property :data, Array, desc: "Quests" do
            param_group :quest_serializer_atributes, QuestsControllerDoc
          end
          property :meta, Hash, desc: "Hash with pagination info" do
            param_group :pagination, Docs::V1::PaginationDoc
          end
        end

        error code: 403, desc: "Unauthorized"
      end
    end
  end
end
