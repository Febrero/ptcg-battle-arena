module Docs
  module V1
    module SampleDecksControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :sample_decks_serializer_atributes do
        property :id, String, desc: "Sample Deck ID"
        property :type, String, desc: "Sample Deck type"
        property :attributes, Hash, desc: "Sample Deck attributes" do
          property :level, Integer, desc: "Sample Deck level"
          property :video_ids, Array, desc: "Sample Deck video IDs"
        end
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/sample_decks", "List of sample decks (Authenticated)"
      def_param_group :sample_decks_controller_index do
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Sample Decks" do
            param_group :sample_decks_serializer_atributes, SampleDecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/sample_decks/:id", "Sample decks (Authenticated)"
      def_param_group :sample_decks_controller_show do
        returns code: 200, desc: "Success" do
          property :data, Hash, desc: "Sample Decks" do
            param_group :sample_decks_serializer_atributes, SampleDecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :POST, "/sample_decks", "Create Sample Deck (Authenticated)"
      def_param_group :sample_decks_controller_create do
        param :level, Integer, desc: "Sample Deck level", required: true
        param :video_ids, Array, desc: "Sample Deck video IDs", required: true
        returns code: 200, desc: "Success" do
          property :data, Hash, desc: "Sample Decks" do
            param_group :sample_decks_serializer_atributes, SampleDecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
        error code: 400, desc: "Form errors"
      end

      # api :PUT, "/sample_decks/:id", "Update Sample Deck (Authenticated)"
      def_param_group :sample_decks_controller_update do
        param :id, String, desc: "Sample Deck id", required: true
        param :level, Integer, desc: "Sample Deck level", required: true
        param :video_ids, Array, desc: "Sample Deck video IDs", required: true
        returns code: 200, desc: "Success" do
          property :data, Hash, desc: "Sample Decks" do
            param_group :sample_decks_serializer_atributes, SampleDecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
        error code: 400, desc: "Form errors"
      end

      # api :DELETE, "/sample_decks/:id", "Delete Sample Deck (Authenticaded)"
      def_param_group :sample_decks_controller_destroy do
        returns code: 200, desc: "Sample Deck deleted" do
          property :success, [true, false], desc: "Sample Deck deletion status"
        end
        error code: 400, desc: "Not deleted"
        error code: 403, desc: "Unauthorized"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
