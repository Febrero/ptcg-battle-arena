module V1
  class GameModePartnerConfigsController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :auth_external_api
    before_action :set_partner_config, only: %i[show update destroy]
    around_action :use_read_only_databases, only: [:index, :show]

    def index
      collection, page, per_page, total = ::GameModePartnerConfigsSearch.new(search_params).search

      render json: collection,
        each_serializer: GameModePartnerConfigSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    def show
      if @partner_config
        render json: @partner_config,
          serializer: GameModePartnerConfigSerializer,
          adapter: :json_api,
          status: :ok
      else
        head :not_found
      end
    end

    def create
      partner_config = GameModePartnerConfig.new(partner_config_params)
      if partner_config.save
        render json: partner_config,
          serializer: GameModePartnerConfigSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: partner_config,
          serializer: ActiveModel::Serializer::ErrorSerializer,
          adapter: :json_api,
          status: :unprocessable_entity
      end
    end

    def update
      return head :not_modified if params[:data][:attributes].empty?

      if @partner_config.update(partner_config_params)
        render json: @partner_config,
          serializer: GameModePartnerConfigSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: @partner_config,
          serializer: ActiveModel::Serializer::ErrorSerializer,
          adapter: :json_api,
          status: :unprocessable_entity
      end
    end

    def destroy
      if @partner_config.game_modes.count == 0
        @partner_config.destroy
        head :no_content
      else
        render json: {
          error: "It is not possible to delete the #{@partner_config.name} configuration because it has associated game modes"
        }, status: :conflict
      end
    end

    private

    def search_params
      params.permit(filter: [:name])
    end

    def partner_config_params
      params.require(:data).require(:attributes).permit(
        :name,
        custom_maps_settings: [
          practice: {},
          lisbon: {},
          rune: {},
          miami: {}
        ]
      )
    end

    def set_partner_config
      @partner_config = GameModePartnerConfig.where(uid: params[:uid]).first
    end
  end
end
