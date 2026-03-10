module Docs
  module V1
    module TicketOffersControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/ticket_offers", "Ticket Offers Index"
      def_param_group :ticket_offers_controller_index do
        param :ticket_id, Integer, desc: "Ticket Id"
        param :quantity, Integer, desc: "Quantity Tickets"
        param :wallet_addr, String, desc: "Wallet address"
        param :offered, [true, false], desc: "Whether ticket was already delivered or not"
        param :tx_hash, String, desc: "Blockchain transaction hash"
        param :order, String, desc: "Sort order"
        param :page, Integer, desc: "Page number"
        param :per_page, Integer, desc: "Number of items per page"
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Ticket offers list" do
            property :ticket_id, Integer, desc: "Ticket Id"
            property :quantity, Integer, desc: "Quantity Tickets"
            property :wallet_addr, String, desc: "Wallet address"
            property :offered, [true, false], desc: "Whether ticket was already delivered or not"
            property :tx_hash, String, desc: "Blockchain transaction hash"
          end
        end
        error code: 403, desc: "Unauthorized"
      end

      # api :GET, "/ticket_offers/id", "Ticket offers details"
      def_param_group :ticket_offers_controller_show do
        returns code: 200, desc: "Ticket Offers"
        error code: 403, desc: "Forbidden"
      end

      # api :POST, "/ticket_offers", "Create ticket offers"
      def_param_group :ticket_offers_controller_create do
        param :ticket_id, Integer, desc: "Ticket Id"
        param :wallet_addr, String, desc: "Wallet Address"
        param :quantity, Integer, desc: "Quantity of tickets"
        returns code: 200, desc: "Success"
        error code: 403, desc: "Unauthorized"
      end

      # api :PUT "/ticket_offers/:id", "Update ticket offer"
      def_param_group :ticket_offers_controller_update do
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Ticket offers list" do
            property :ticket_id, Integer, desc: "Ticket Id"
            property :quantity, Integer, desc: "Quantity Tickets"
            property :wallet_addr, String, desc: "Wallet address"
            property :offered, [true, false], desc: "Whether ticket was already delivered or not"
            property :tx_hash, String, desc: "Blockchain transaction hash"
          end
        end
        returns code: 400, desc: "Bad request" do
          param :error, String, "Error message"
        end
      end

      # api :PUT "/ticket_offers/export_csv", "Sends ticket offers csv export to email address"
      def_param_group :ticket_offers_controller_export_csv do
        returns code: 200, desc: "Success" do
          param :message, String, "Success message"
        end
        returns code: 500, desc: "Internal server error" do
          param :error, String, "Error message"
        end
      end
      ########## ACTIONS DOC END ############
    end
  end
end
