module V1
  class ArenasController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::ArenasControllerDoc

    before_action :set_arena, only: [:show, :update, :destroy]
    before_action :auth_frontend, only: [:index, :show]
    before_action :auth_external_api, only: [:create, :update, :destroy]
    around_action :use_read_only_databases, only: [:index]

    api :GET, "/arenas", "List of arenas (Authenticaded)"
    param_group :arenas_controller_index, Docs::V1::ArenasControllerDoc
    def index
      collection, page, per_page, total = ::ArenasSearch.new(search_params).search

      render json: collection,
        each_serializer: ArenaSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/arenas/:id", "Show arena (Authenticaded)"
    param_group :arenas_controller_show, Docs::V1::ArenasControllerDoc
    def show
      if @arena
        render json: @arena, serializer: ArenaSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/arenas", "Create arena (Authenticaded)"
    param_group :arenas_controller_create, Docs::V1::ArenasControllerDoc
    def create
      arena = Arena.new(arena_params)
      if arena.save
        render json: arena, serializer: ArenaSerializer, adapter: :json_api, status: :ok
      else
        render json: arena.errors.messages, status: :bad_request
      end
    end

    api :PUT, "/arenas/:id", "Update arena (Authenticaded)"
    param_group :arenas_controller_update, Docs::V1::ArenasControllerDoc
    def update
      if @arena.update(arena_params)
        render json: @arena, serializer: ArenaSerializer, adapter: :json_api, status: :ok
      else
        render json: @arena.errors.messages, status: :bad_request
      end
    end

    api :DELETE, "/arenas/:id", "Delete arena (Authenticaded)"
    param_group :arenas_controller_destroy, Docs::V1::ArenasControllerDoc
    def destroy
      @arena.destroy
      head :no_content
    end

    private

    def set_arena
      @arena = Arena.where(id: params[:id]).first
    end

    def arena_params
      params.require(:data).require(:attributes).permit(
        :uid,
        :name,
        :total_prize_pool,
        :prize_pool_winner_share,
        :prize_pool_realfevr_share,
        :erc20_name,
        :active,
        :image_url,
        :background_image_url,
        :card_image_url,
        :ticket_factory_contract_address,
        :ticket_locker_and_distribution_contract_address,
        :rewards_multiplier,
        :entry_price_image_url,
        :partner_config,
        :erc20_image_url,
        layout_colors: [],
        compatible_ticket_ids: []
      )
    end

    def search_params
      params.permit(:page, :per_page, filter: [:admin_only, :admin, :active])
    end
  end
end
