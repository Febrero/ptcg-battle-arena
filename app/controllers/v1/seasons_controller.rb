module V1
  class SeasonsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::SeasonsControllerDoc

    before_action :set_season, only: [:show, :update, :destroy]
    before_action :auth_frontend, only: [:index, :show]
    before_action :auth_external_api, only: [:create, :update, :destroy]
    around_action :use_read_only_databases, only: [:index]

    api :GET, "/seasons", "List of seasons (Authenticaded)"
    param_group :seasons_controller_index, Docs::V1::SeasonsControllerDoc
    def index
      collection, page, per_page, total = ::SeasonsSearch.new(search_params).search

      render json: collection,
        each_serializer: SeasonSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/seasons/:id", "Show season (Authenticaded)"
    param_group :seasons_controller_show, Docs::V1::SeasonsControllerDoc
    def show
      if @season
        render json: @season, serializer: SeasonSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/seasons", "Create season (Authenticaded)"
    param_group :seasons_controller_create, Docs::V1::SeasonsControllerDoc
    def create
      season = Season.new(season_params)
      if season.save
        render json: season, serializer: SeasonSerializer, adapter: :json_api, status: :ok
      else
        render json: season_params, status: :bad_request
      end
    end

    api :PUT, "/seasons/:id", "Update season (Authenticaded)"
    param_group :seasons_controller_update, Docs::V1::SeasonsControllerDoc
    def update
      if @season.update(season_params)
        render json: @season, serializer: SeasonSerializer, adapter: :json_api, status: :ok
      else
        render json: @season.errors.messages, status: :bad_request
      end
    end

    # api :DELETE, "/season/:id", "Delete season (Authenticaded)"
    # param_group :seasons_controller_destroy, Docs::V1::SeasonsControllerDoc
    # def destroy
    #   @season.destroy
    #   head :no_content
    # end

    private

    def set_season
      @season = Season.unscoped.where(uid: params[:id]).first
    end

    def season_params
      season_parameters = params.require(:data).require(:attributes).permit(
        :uid,
        :name,
        :start_date,
        :end_date,
        :active
      )

      season_parameters[:start_date] = season_parameters[:start_date].to_i if season_parameters[:start_date]
      season_parameters[:end_date] = season_parameters[:end_date].to_i if season_parameters[:end_date]
      season_parameters
    end

    def search_params
      params.permit(filter: [:active], page: [:page, :per_page])
    end
  end
end
