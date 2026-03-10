module V1
  class AssistedGamersController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :auth_external_api
    before_action :set_assisted_gamer, only: %i[show update destroy]
    around_action :use_read_only_databases, only: [:index, :show, :search]

    def search
      gamer = AssistedGamerSearch.search(search_params, true)
      if gamer
        gamer.update(last_selected_at: Time.now)
        render json: gamer,
          serializer: AssistedGamerSerializer,
          deck_stars: params[:deck_stars],
          adapter: :json_api,
          status: :ok
      else
        render json: {},
          status: :not_found
      end
    end

    # TODO CRUD for ADMIN
    def index
      collection, page, per_page, total = ::AssistedGamerSearch.new(search_params).search

      render json: collection,
        each_serializer: AssistedGamerSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    def show
      if @assisted_gamer
        render json: @assisted_gamer,
          serializer: AssistedGamerSerializer,
          adapter: :json_api,
          status: :ok
      else
        head :not_found
      end
    end

    def create
      assisted_gamer = AssistedGamer.new(assisted_gamer_params)

      if assisted_gamer.save
        render json: assisted_gamer,
          serializer: AssistedGamerSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: assisted_gamer,
          serializer: ActiveModel::Serializer::ErrorSerializer,
          adapter: :json_api,
          status: :unprocessable_entity
      end
    end

    def update
      if @assisted_gamer.update(assisted_gamer_params)
        render json: @assisted_gamer,
          serializer: AssistedGamerSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: @assisted_gamer,
          serializer: ActiveModel::Serializer::ErrorSerializer,
          adapter: :json_api,
          status: :unprocessable_entity
      end
    end

    def destroy
      @assisted_gamer.destroy
      head :no_content
    end

    def upload_csv
      AssistedGamersImporter.import(params[:csv])
      head :ok
    end

    private

    def set_assisted_gamer
      @assisted_gamer = AssistedGamer.where(id: params[:id]).first
    end

    def search_params
      params.permit(:deck_stars, :game_mode, filter: [:wallet_addr, :ai_mode, :week_days_that_play, :day_hours_that_play])
    end

    def assisted_gamer_params
      params.require(:data).require(:attributes).permit(
        :wallet_addr,
        :ai_mode,
        :max_daily_games,
        day_hours_that_play: [],
        week_days_that_play: []
      )
    end
  end
end
