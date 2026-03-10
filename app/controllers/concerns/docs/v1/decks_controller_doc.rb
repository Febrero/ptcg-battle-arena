module Docs
  module V1
    module DecksControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :deck_info do
        property :name, String, desc: "Deck name"
        property :flag_status, String, desc: "Flag status"
        property :nfts_count, Integer, desc: "Count of nfts"
        property :grey_cards_count, Integer, desc: "Count of grey cards"
      end

      def_param_group :deck_response do
        property :uid, Integer, desc: "UID of NFT"
        property :video_id, Integer, desc: "UID of the video "
        property :position, Integer, desc: "Position of Player"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/decks/list", "List of decks (Authenticaded)"
      def_param_group :decks_controller_list do
        returns code: 200, desc: "Deck" do
          property :data, Array, desc: "Deck" do
            param_group :deck_info, DecksControllerDoc
            property :nfts, Array, desc: "Array of deck meta info " do
              param_group :deck_response, DecksControllerDoc
            end
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/decks", "List of decks (Authenticaded)"
      def_param_group :decks_controller_index do
        returns code: 200, desc: "Deck" do
          property :data, Array, desc: "Deck" do
            param_group :deck_info, DecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/decks/user", "List of user decks (Authenticaded)"
      def_param_group :decks_controller_user_index do
        returns code: 200, desc: "Deck" do
          property :data, Array, desc: "Deck" do
            param_group :deck_info, DecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/decks/:id", "List of deck nft's"
      def_param_group :decks_controller_show do
        param :id, Integer, desc: "ID if deck", required: true
        returns code: 200, desc: "Deck info" do
          param_group :deck_info, DecksControllerDoc
          property :nfts, Array, desc: "Array of deck meta info " do
            param_group :deck_response, DecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/decks/:id/user", "List of user decks"
      def_param_group :decks_controller_user_show do
        param :id, Integer, desc: "ID if deck", required: true
        returns code: 200, desc: "Deck info" do
          param_group :deck_info, DecksControllerDoc
          property :nfts, Array, desc: "Array of deck meta info " do
            param_group :deck_response, DecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :POST, "/decks", "Create deck (Authenticaded)"
      def_param_group :decks_controller_create do
        param :nft_ids, Array, desc: "Ids of the nft", required: true
        param :wallet_addr, String, desc: "Owner address", required: true
        property :name, String, desc: "deck name", required: true
        returns code: 200, desc: "Deck info" do
          param_group :deck_info, DecksControllerDoc
          property :nfts, Array, desc: "Array of deck meta info " do
            param_group :deck_response, DecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
        error code: 400, desc: "Form errors"
      end

      # api :POST, "/remove_on_sale_nft_from_decks", "Remove on sale nft from decks"
      def_param_group :decks_controller_remove_on_sale_nft_from_decks do
        param :nft_id, Integer, desc: "Id of the nft", required: true
        returns code: 200, desc: "Nft Remove Status" do
          property :success, [true], desc: "Nft deletion status"
        end
      end

      # api :PUT, "/decks/:id", "Update deck (Authenticaded)"
      def_param_group :decks_controller_update do
        param :nft_ids, Array, desc: "Ids of the nft"
        param :wallet_addr, String, desc: "Owner address"
        property :name, String, desc: "deck name"
        returns code: 200, desc: "Deck info" do
          param_group :deck_info, DecksControllerDoc
          property :nfts, Array, desc: "Array of deck meta info " do
            param_group :deck_response, DecksControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
        error code: 400, desc: "Form errors"
      end

      # api :DELETE, "/decks/:id", "delete decks (Authenticaded)"
      def_param_group :decks_controller_destroy do
        returns code: 200, desc: "Deck deleted" do
          property :success, [true, false], desc: "Deck deletion status"
        end
        error code: 400, desc: "Not deleted"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
