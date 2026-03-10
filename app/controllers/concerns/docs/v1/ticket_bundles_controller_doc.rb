module Docs
  module V1
    module TicketBundlesControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :ticket_bundle_serializer_attributes do
        property :image_url, String, desc: "Ticket bundle image URL"
        property :tickets_quantity, Integer, desc: "Tickets quantity"
        property :old_price, Float, desc: "Old price"
        property :discount, Float, desc: "Discount"
        property :final_price, Float, desc: "Final price"
        property :name, String, desc: "Ticket bundle name"
        property :slug, String, desc: "Ticket bundle slug"
        property :order, Float, desc: "Ticket bundle order"
        property :sale_expiration_date, DateTime, desc: "Ticket bundle expiration time"
        property :bc_ticket_id, Integer, desc: "Blockchain ticket id"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/ticket_bundles", "List of ticket bundles (Authenticaded)"
      def_param_group :ticket_bundles_controller_index do
        returns code: 200, desc: "Ticket bundle" do
          property :data, Array, desc: "Ticket bundle" do
            param_group :ticket_bundle_serializer_attributes, TicketBundlesControllerDoc
          end
        end
        error code: 403, desc: "Forbidden"
      end

      # api :GET, "/ticket_bundles/id", "Ticket bundle details (Authenticaded)"
      def_param_group :ticket_bundles_controller_show do
        returns code: 200, desc: "Ticket bundle" do
          param_group :ticket_bundle_serializer_attributes, TicketBundlesControllerDoc
        end
        error code: 403, desc: "Forbidden"
      end

      # api :POST, "/ticket_bundles", "Create ticket bundle (Authenticaded)"s
      def_param_group :ticket_bundles_controller_create do
        returns code: 200, desc: "Ticket bundle" do
          param_group :ticket_bundle_serializer_attributes, TicketBundlesControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :PUT, "/ticket_bundles/:id", "Update ticket bundle (Authenticaded)"
      def_param_group :ticket_bundles_controller_update do
        returns code: 200, desc: "Ticket bundle" do
          param_group :ticket_bundle_serializer_attributes, TicketBundlesControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :DELETE, "/ticket_bundles/:id", "Delete ticket_bundle (Authenticaded)"
      def_param_group :ticket_bundles_controller_destroy do
        returns code: 204, desc: "No content"
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
