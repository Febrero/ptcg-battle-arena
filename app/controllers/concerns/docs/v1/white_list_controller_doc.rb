module Docs
  module V1
    module WhiteListControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/white_list", "List of wallets that can play the alpha game version (Authenticaded)"
      def_param_group :white_list_controller_index do
        returns code: 200, desc: "Addresses" do
          property :data, Array, desc: "Addresses"
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/white_list/:address", "Check if wallet is white listed (Authenticated)"
      def_param_group :white_list_controller_show do
        param :address, String, desc: "Wallet address"
        returns code: 200, desc: "Success" do
          property :data, Hash, desc: "Wallet hash" do
            property :id, String, desc: "Wallet ID"
            property :type, String, desc: "Wallet type"
            property :attributes, Hash, desc: "Wallet attributes" do
              property :address, String, desc: "Wallet address"
              property :roles, Array, desc: "Wallet roles"
            end
          end
        end
        error code: 404, desc: "Not found"
        error code: 403, desc: "Unauthorized"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
