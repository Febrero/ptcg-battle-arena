module V1
  class SurvivalsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    # include Docs::SurvivalsControllerDoc

    before_action :get_survival, only: [:show, :update, :destroy]
    before_action :auth_frontend, only: [:index, :show]
    before_action :auth_internal_api, only: [:create, :update, :destroy]
    around_action :use_read_only_databases

    api :GET, "/survivals", "List of survivals (Authenticaded)"
    # param_group :survivals_controller_index, Docs::V1::ArenasControllerDoc
    def index
      collection, page, per_page, total = ::SurvivalsSearch.new(search_params).search

      render json: collection,
        each_serializer: SurvivalSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/survivals/:uid", "Survival details (Authenticaded)"
    # param_group :survivals_controller_show, Docs::V1::ArenasControllerDoc
    def show
      if @survival
        render json: @survival,
          serializer: SurvivalSerializer,
          adapter: :json_api,
          status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/survivals", "Create survival (Authenticated)"
    # param_group :survivals_controller_show, Docs::V1::ArenasControllerDoc
    def create
      survival = Survival.new(survival_params)
      if survival.save
        render json: survival, serializer: SurvivalSerializer, adapter: :json_api, status: :ok
      else
        render json: survival.errors.messages, status: :bad_request
      end
    end

    api :PUT, "/survivals/:uid", "Update survival (Authenticated)"
    # param_group :arenas_controller_update, Docs::V1::ArenasControllerDoc
    def update
      if @survival.update(survival_params)
        render json: @survival, serializer: SurvivalSerializer, adapter: :json_api, status: :ok
      else
        render json: @survival.errors.messages, status: :bad_request
      end
    end

    api :DELETE, "/survivals/:uid", "Delete survival (Authenticated)"
    # param_group :arenas_controller_destroy, Docs::V1::ArenasControllerDoc
    def destroy
      @survival.destroy
      head :no_content
    end

    private

    def get_survival
      @survival = Survival.where(uid: params[:uid]).first
    end

    def search_params
      params.permit(filter: [:state, :active, :admin, :admin_only], page: [:page, :per_page])
    end

    def survival_params
      params.require(:data).require(:attributes).permit(
        :name,
        :total_prize_pool,
        :prize_pool_winner_share,
        :prize_pool_realfevr_share,
        :active,
        :erc20_name,
        :ticket_factory_contract_address,
        :ticket_locker_and_distribution_contract_address,
        :state,
        :start_date,
        :end_date,
        :min_deck_tier,
        :max_deck_tier,
        :levels_count,
        :card_image_url,
        :background_image_url,
        :entry_price_image_url,
        :rewards_multiplier,
        :home_highlight,
        :home_highlight_image_url,
        :home_highlight_image_mobile_url,
        :partner_config,
        layout_colors: [],
        compatible_ticket_ids: [],
        stages: [:level, :prize_amount, :prize_type, :prize_image_url]
      )
    end
  end
end
