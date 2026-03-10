module Docs
  module V1
    module RewardsControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :wallet_rewards_serializer do
        property :wallet_addr, String, desc: "Wallet address"
        property :total_xp, Integer, desc: "Total xp earned"
        property :white_list_tickets, Integer, desc: "Number of white list tickets earned"
        property :total_fevr_earned, Integer, desc: "Total fevr earned"
        property :total_nfts_earned, Integer, desc: "Total nfts earned"
        property :total_packs_earned, Integer, desc: "Total packs earned"
        property :xp_level, Integer, desc: "Current XP level"
        property :level_floor_xp, Integer, desc: "Floor XP of current XP level"
        property :level_ceil_xp, Integer, desc: "Ceil XP of current XP level"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/rewards/wallet", "Wallet rewards info"
      def_param_group :rewards_controller_wallet do
        returns code: 200, desc: "Addresses" do
          param_group :wallet_rewards_serializer, RewardsControllerDoc
        end
        error code: 401, desc: "Unauthorized"
        error code: 403, desc: "Forbidden"
        error code: 404, desc: "Wallet not found"
        error code: 408, desc: "Server Timeout"
        error code: 500, desc: "Internal Server Error"
      end

      ########## ACTIONS DOC END ############
    end
  end
end
