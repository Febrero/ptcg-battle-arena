module Docs
  module V1
    module VideosControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :video_serializer_attributes do
        property :wallet_addr, String, desc: "Owner Address"
        property :uid, Integer, desc: "Uid of Video"
        property :rarity, String, desc: "Rarity of Video"
        property :player_name, String, desc: "Player name of Video"
        property :drop, String, desc: "Drop acronym"
        property :position, String, desc: "Player position"
        property :defense, Integer, desc: "Player defense"
        property :stamina, Integer, desc: "Player stamina"
        property :attack, Integer, desc: "Player attack"
        property :man_mark, String, desc: "Player man_mark"
        property :inspire, String, desc: "Inspire of card"
        property :captain, String, desc: "Captain of card"
        property :long_passer, [true, false], desc: "Long passer of card"
        property :box_to_box, [true, false], desc: "Box to box of card"
        property :dribbler, [true, false], desc: "Dribbler of card"
        property :nfts, Array, desc: "Nfts uids"
      end

      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/videos", "NFT game video info index (Authenticaded)"
      def_param_group :videos_controller_index do
        returns code: 200, desc: "NFT Videos Metainfo for Game" do
          property :uid, Integer, desc: "Video UID"
          property :rarity, Integer, desc: "Rariry of NFT"
          property :drop, String, desc: "Drop of NFT"
          property :position, String, desc: "Position of Player"
          property :defense, String, desc: "Defense of Card"
          property :attack, String, desc: "Attack of Card"
          property :stamina, String, desc: "Stamina of Card"
          property :ball_stopper, [true, false], desc: "Ball Stopper of Card"
          property :super_sub, [true, false], desc: "Super Sub of Card"
          property :man_mark, Integer, desc: "Man mark of Card"
          property :enforcer, [true, false], desc: "Enforcer of Card"
          property :inspire, String, desc: "Inspire of card"
          property :captain, String, desc: "Captain of card"
          property :long_passer, [true, false], desc: "Long passer of card"
          property :box_to_box, [true, false], desc: "Box to box of card"
          property :dribbler, [true, false], desc: "Dribbler of card"
        end
      end

      # api :GET, "/wallet_collection", "Get filtered user wallet videos (Authenticaded)"
      def_param_group :videos_controller_wallet_collection do
        param :type, String, desc: "Type of the pack to sample (basic, rare or super_rare)", required: true
        returns code: 200, desc: "WalletVideo" do
          property :data, Array, desc: "WalletVideos" do
            param_group :video_serializer_attributes, VideosControllerDoc
          end
          property :meta, Hash, desc: "Hash with pagination info" do
            param_group :pagination, Docs::V1::PaginationDoc
          end
        end
      end

      # api :PUT, "/videos", "Update video (Authenticaded)"
      def_param_group :videos_controller_update do
        param :nft_uid, Integer, desc: "NFT UID", required: true
        param :old_owner_addr, String, desc: "Address of old owner", required: true
        param :new_owner_addr, String, desc: "Address of new owner", required: true
        returns code: 200, desc: "WalletVideo" do
          property :data, Hash, desc: "WalletVideo" do
            param_group :video_serializer_attributes, VideosControllerDoc
          end
        end
        returns code: 200, desc: "Empty response if video gets deleted"
        error code: 403, desc: "Unauthorized"
      end

      # api :PUT, "/videos", "Update video (Authenticaded)"
      def_param_group :videos_controller_update_wallet_video_data do
        param :wallet_addr, String, desc: "Wallet Address", required: true
        param :uid, Integer, desc: "Wallet Video UID", required: true
        param :nfts, Array, desc: "List of Nfts UIDs", required: true
        returns code: 200, desc: "WalletVideo" do
          property :data, Hash, desc: "WalletVideo" do
            param_group :video_serializer_attributes, VideosControllerDoc
          end
        end
        error code: 403, desc: "Unauthorized"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
