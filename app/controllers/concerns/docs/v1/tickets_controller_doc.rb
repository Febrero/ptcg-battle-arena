module Docs
  module V1
    module TicketsControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :tickets_serializer_atributes do
        property :bc_ticket_id, Integer, desc: "Blockchain ticket id"
        property :name, String, desc: "Ticket name"
        property :description, String, desc: "Ticket description"
        property :erc20, String, desc: "Ticket erc20"
        property :base_price, Integer, desc: "Ticket base price"
        property :start_date, Time, desc: "Ticket start date"
        property :expiration_date, Time, desc: "Ticket expiration date"
        property :available_quantities, Array, desc: "Ticket available quantities"
        property :image_url, String, desc: "Ticket image url"
        property :active, [true, false], desc: "Ticket active"
      end

      def_param_group :tickets_public_serializer_atributes do
        property :uid, Integer, desc: "Blockchain ticket id"
        property :name, String, desc: "Ticket name"
        property :description, String, desc: "Ticket description"
        property :price, Integer, desc: "Ticket base price"
        property :erc20, Integer, desc: "ERC20 contract address"
        property :expire_date, Integer, desc: "Ticket expiration date (unix timestamp)"
        property :image, String, desc: "Arena image url"
        property :attributes, Array, desc: "Attributes" do
          property :trait_type, String, desc: "Trait type"
          property :value, String, desc: "Trait value"
        end
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/tickets", "Tickets index (authenticated)"
      def_param_group :ticket_controller_index do
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Data" do
            param_group :tickets_serializer_atributes, TicketsControllerDoc
          end
        end
        error code: 403, desc: "Forbidden"
      end

      # api :GET, "/tickets/meta/bc_ticket_uid", "Ticket detail (public)"
      def_param_group :ticket_controller_meta do
        returns code: 200, desc: "Success" do
          param_group :tickets_public_serializer_atributes, TicketsControllerDoc
        end
      end

      # api :GET, "/tickets/:id", "Ticket detail (authenticated)"
      def_param_group :ticket_controller_show do
        returns code: 200, desc: "Success" do
          param_group :tickets_serializer_atributes, TicketsControllerDoc
        end
        error code: 403, desc: "Forbidden"
      end

      # api :POST, "/tickets", "Create ticket (authenticated)"
      def_param_group :ticket_controller_create do
        returns code: 200, desc: "Success" do
          param_group :tickets_serializer_atributes, TicketsControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :PUT, "/tickets/:id", "Update ticket (authenticated)"
      def_param_group :ticket_controller_update do
        returns code: 200, desc: "Success" do
          param_group :tickets_serializer_atributes, TicketsControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :DELETE, "/tickets/:id", "Delete ticket (authenticated)"
      def_param_group :ticket_controller_destroy do
        returns code: 204, desc: "No content"
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
