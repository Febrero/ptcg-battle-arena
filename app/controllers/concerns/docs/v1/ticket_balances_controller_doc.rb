module Docs
  module V1
    module TicketBalancesControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :ticket_balances_serializer_atributes do
        property :wallet_addr, String, desc: "Wallet address"
        property :balance, Integer, desc: "Ticket balance not deposited"
        property :deposited, Integer, desc: "Deposited tickets"
        property :bc_ticket_id, Integer, desc: "Blockchain ticket id"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/ticket_balances/user", "Ticket balances index"
      def_param_group :ticket_balances_controller_user do
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Data" do
            param_group :ticket_balances_serializer_atributes, TicketBalancesControllerDoc
          end
        end
        error code: 403, desc: "Forbidden"
      end

      def_param_group :ticket_balances_controller_spend do
        param :players, Array, desc: "List of players" do
          param :bc_ticket_id, Integer, desc: "Blockchain ticket id", required: true
          param :wallet_addr, String, desc: "Wallet addr", required: true
        end
        returns code: 200, desc: "Success"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
