module V1
  class TicketsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::TicketsControllerDoc

    before_action :auth_frontend, :check_zero_fees_whitelist_presence, only: [:index, :by_game_mode]
    before_action :auth_external_api, only: [:show, :create, :update, :destroy]
    before_action :set_ticket, only: [:show, :update, :destroy]
    around_action :use_read_only_databases, only: %i[index show]

    api :GET, "/tickets", "List of tickets (Authenticaded)"
    param_group :ticket_controller_index, Docs::V1::TicketsControllerDoc
    def index
      params[:filter] = params[:filters] if params[:filters].present?
      collection, page, per_page, total = ::TicketSearch.new(search_params).search

      render json: collection,
        each_serializer: TicketSerializer,
        zero_fees: @zero_fees,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/tickets/meta/:id", "Ticket detail (public)"
    param_group :ticket_controller_meta, Docs::V1::TicketsControllerDoc
    def meta
      ticket = Ticket.where(bc_ticket_id: params[:bc_ticket_id]).first
      render json: ticket,
        serializer: TicketPublicSerializer,
        status: :ok
    end

    api :GET, "/tickets/:id", "Ticket detail (private)"
    param_group :ticket_controller_show, Docs::V1::TicketsControllerDoc
    def show
      if @ticket
        render json: @ticket, serializer: TicketSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :GET, "/tickets/by_game_mode", "List of tickets by game mode(Authenticaded)"
    def by_game_mode
      tickets = Ticket.by_game_mode
      result = {
        arena: tickets["arena"].to_a.map { |t| TicketSerializer.new(t) },
        survival: tickets["survival"].to_a.map { |t| TicketSerializer.new(t) },
        playoff: tickets["playoff"].to_a.map { |t| TicketSerializer.new(t) }
      }
      render json: result, adapter: :json_api, status: :ok
    end

    api :POST, "/tickets", "Create ticket (Authenticaded)"
    param_group :ticket_controller_create, Docs::V1::TicketsControllerDoc
    def create
      ticket = Ticket.new(ticket_params)
      if ticket.save
        render json: ticket, serializer: TicketSerializer, status: :ok
      else
        render json: ticket.errors, status: :bad_request
      end
    end

    api :PUT, "/tickets/:id", "Update ticket (Authenticaded)"
    param_group :ticket_controller_update, Docs::V1::TicketsControllerDoc
    def update
      if @ticket.update(ticket_params)
        render json: @ticket, serializer: TicketSerializer, status: :ok
      else
        render json: @ticket.errors, status: :bad_request
      end
    end

    api :DELETE, "/tickets/:id", "Delete ticket (Authenticaded)"
    param_group :ticket_controller_destroy, Docs::V1::TicketsControllerDoc
    def destroy
      if @ticket.destroy
        render status: :no_content
      end
    end

    private

    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def ticket_params
      params.require(:data).require(:attributes).permit(
        :bc_ticket_id,
        :name,
        :start_date,
        :base_price,
        :erc20_name,
        :expiration_date,
        :sale_expiration_date,
        :description,
        :image_url,
        :entry_image_url,
        :active,
        :position,
        :ticket_factory_contract_address,
        :ticket_locker_and_distribution_contract_address,
        :zero_fees,
        :promo,
        :game_mode,
        fees: [],
        discount: [],
        tickets_num_discount: [],
        available_quantities: []
      )
    end

    def search_params
      params.permit(:sort, :page, :per_page, filter: [:active, :zero_fees, :game_mode, :id, :bc_ticket_id, :ticket_factory_contract_address], page: {})
    end

    def check_zero_fees_whitelist_presence
      return unless request.headers["Authorization"]
      authenticate_user!
      addr = begin
        @user_data["publicAddress"]
      rescue
        nil
      end
      @zero_fees = GetWalletWhiteListPresence.call(addr, "zero-fee-campaign").present?
    end
  end
end
