module V1
  class TicketBundlesController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::TicketBundlesControllerDoc

    before_action :set_ticket_bundle, only: [:show, :update, :destroy]
    before_action :auth_frontend, only: [:index, :show]
    before_action :auth_external_api, except: [:index, :show]
    around_action :use_read_only_databases, only: [:index]

    api :GET, "/ticket_bundles", "List of ticket bundles (Authenticaded)"
    param_group :ticket_bundles_controller_index, Docs::V1::TicketBundlesControllerDoc
    def index
      collection, page, per_page, total = ::TicketBundlesSearch.new(
        search_params, TicketBundle.order_by(order: :asc)
      ).search

      render json: collection,
        each_serializer: TicketBundleSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/ticket_bundles/:id", "Show ticket bundle (Authenticaded)"
    param_group :ticket_bundles_controller_show, Docs::V1::TicketBundlesControllerDoc
    def show
      if @ticket_bundle
        render json: @ticket_bundle, serializer: TicketBundleSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/ticket_bundles", "Create ticket bundle (Authenticaded)"
    param_group :ticket_bundles_controller_create, Docs::V1::TicketBundlesControllerDoc
    def create
      ticket_bundle = TicketBundle.new(ticket_bundle_params)
      if ticket_bundle.save
        render json: ticket_bundle, serializer: TicketBundleSerializer, adapter: :json_api, status: :ok
      else
        render json: ticket_bundle.errors.messages, status: :bad_request
      end
    end

    api :PUT, "/ticket_bundles/:id", "Update ticket bundle (Authenticaded)"
    param_group :ticket_bundles_controller_update, Docs::V1::TicketBundlesControllerDoc
    def update
      if @ticket_bundle.update(ticket_bundle_params)
        render json: @ticket_bundle, serializer: TicketBundleSerializer, adapter: :json_api, status: :ok
      else
        render json: @ticket_bundle.errors.messages, status: :bad_request
      end
    end

    api :DELETE, "/ticket_bundles/:id", "Delete ticket bundle (Authenticaded)"
    param_group :ticket_bundles_controller_destroy, Docs::V1::TicketBundlesControllerDoc
    def destroy
      @ticket_bundle.destroy
      head :no_content
    end

    private

    def set_ticket_bundle
      @ticket_bundle = TicketBundle.where(id: params[:id]).first
    end

    def ticket_bundle_params
      params.require(:data).require(:attributes).permit(
        :name,
        :slug,
        :image_url,
        :tickets_quantity,
        :old_price,
        :discount,
        :final_price,
        :order,
        :sale_expiration_date,
        :ticket_factory_contract_address,
        :ticket_locker_and_distribution_contract_address,
        :ticket_id
      )
    end

    def search_params
      params.permit(:page, :per_page)
    end
  end
end
