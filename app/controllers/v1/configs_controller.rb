module V1
  class ConfigsController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :auth_frontend, only: [:index, :game, :site]
    before_action :authenticate_user!, only: [:home]

    api :GET, "/configs", "Configs (Authenticated)"
    param_group :configs_controller_index, Docs::V1::ConfigsControllerDoc
    def index
      render json: Configs::GetGameConfig.call, status: :ok
    end

    api :GET, "/configs/site", "Configs for RealFevr site (Authenticated)"
    def site
      render json: Configs::GetSiteConfig.call, status: :ok
    end

    api :GET, "/configs/game", "Configs for game (Authenticated)"
    def game
      render json: Configs::GetGameConfig.call, status: :ok
    end

    api :GET, "/configs/home", "Configs for RealFevr home (User Authenticated)"
    def home
      render json: Configs::GetHomeConfig.call(@user_data["publicAddress"]), status: :ok
    end
  end
end
