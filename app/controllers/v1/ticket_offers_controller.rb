module V1
  class TicketOffersController < ApplicationController
    include PaginationMeta
    include BasicAuth
    include Docs::V1::TicketOffersControllerDoc

    before_action :set_ticket_offer, only: [:show, :update]
    before_action :auth_internal_api, only: [:index, :show, :create, :update, :export_csv]
    around_action :use_read_only_databases, only: [:index, :show]

    api :GET, "/ticket_offers", "Ticket Offers Index"
    param_group :ticket_offers_controller_index, Docs::V1::TicketOffersControllerDoc
    def index
      collection, page, per_page, total = ::TicketOffersSearch.new(params).search
      render json: collection,
        each_serializer: TicketOfferSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/ticket_offers/:id", "Show Ticket Offers"
    param_group :ticket_offers_controller_show, Docs::V1::TicketOffersControllerDoc
    def show
      if @ticket_offer
        render json: @ticket_offer, serializer: TicketOfferSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/ticket_offers", "Create Ticket Offers"
    param_group :ticket_offers_controller_create, Docs::V1::TicketOffersControllerDoc
    def create
      CreateTicketOfferJob.perform_async(ticket_offer_params.as_json)
      head :ok
    end

    api :PUT, "/ticket_offers/:id", "Update ticket offers"
    param_group :ticket_offers_controller_update, Docs::V1::TicketOffersControllerDoc
    def update
      update_attributes = ticket_offer_params.merge(delivered_at: Time.now) if ticket_offer_params[:offered]

      if @ticket_offer.update(update_attributes)
        render json: @ticket_offer, serializer: TicketOfferSerializer, adapter: :json_api, status: :ok
      else
        render json: @ticket_offer.errors.messages, status: :bad_request
      end
    end

    api :PUT, "/ticket_offers/export_csv", "Sends ticket offers csv export to email address"
    param_group :ticket_offers_controller_export_csv, Docs::V1::TicketOffersControllerDoc
    def export_csv
      ExportTicketOffersJob.perform_async(params[:email])
      render json: {message: :success}, status: :ok
    rescue => e
      Airbrake.notify(e)
      render json: {error: e.message}, status: :internal_server_error
    end

    private

    def set_ticket_offer
      @ticket_offer = TicketOffer.where(id: params[:id]).first
    end

    def ticket_offer_params
      params.require(:data).require(:attributes).permit(
        :id,
        :quantity,
        :wallet_addr,
        :ticket_factory_contract_address,
        :offered,
        :tx_hash,
        :order,
        :page,
        :per_page,
        :bc_ticket_id,
        :reward_key,
        :source,
        :created_by,
        bc_ticket_id: []
      )
    end
  end
end
