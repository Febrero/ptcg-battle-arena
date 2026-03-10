module V1
  class GameModeController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :get_game_mode, only: [:game_mode_config]
    before_action :external_api, only: [:game_mode_config]
    around_action :use_read_only_databases

    api :GET, "/game_mode/:uid/info", "Game mode details"
    def game_mode_config
      if @game_mode
        render json: @game_mode,
          serializer: GameModeSerializer,
          adapter: :json_api,
          status: :ok
      else
        head :not_found
      end
    end

    private

    def get_game_mode
      @game_mode = GameMode.where(uid: params[:uid].to_i).first
    end
  end
end
