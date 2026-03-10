module V1
  class GamesController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::GamesControllerDoc

    before_action :set_game, only: [:show]
    before_action :auth_external_api
    around_action :use_read_only_databases, only: [:index, :show, :info]

    api :GET, "/games", "List of games (Authenticated)"
    param_group :games_controller_index, Docs::V1::GamesControllerDoc
    def index
      collection, page, per_page, total = ::GamesSearch.new(params).search

      render json: collection,
        each_serializer: GameSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/games/:id", "Show game (Authenticated)"
    param_group :games_controller_show, Docs::V1::GamesControllerDoc
    def show
      if @game
        render json: @game, serializer: GameDetailSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :GET, "/games/by_game_id/:game_id", "Show game (Authenticated)"
    param_group :games_controller_show, Docs::V1::GamesControllerDoc
    def by_game_id
      game = Game.find_by(game_id: params[:game_id])
      render json: game, serializer: GameDetailSerializer, adapter: :json_api, status: :ok
    rescue Mongoid::Errors::DocumentNotFound
      head :not_found
    end

    api :GET, "/games/info", "Games totals info (Authenticated)"
    param_group :games_controller_info, Docs::V1::GamesControllerDoc
    def info
      render json: GetGamesInfo.call, status: :ok
    end

    private

    def set_game
      @game = Game.where(id: params[:id]).first
    end

    def search_params
      params.permit(:sort, filter: [], page: [])
    end
  end
end
