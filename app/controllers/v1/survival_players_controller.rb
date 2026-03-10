module V1
  class SurvivalPlayersController < ApplicationController
    include BasicAuth
    include PaginationMeta
    # include Docs::SurvivalsControllerDoc

    prepend_before_action :authenticate_user!, except: [:index]
    before_action :auth_frontend
    around_action :use_read_only_databases, except: [:create]

    api :GET, "/survival_players", "List of survivals (Authenticaded)"
    # param_group :survivals_controller_index, Docs::V1::ArenasControllerDoc
    def index
      collection, page, per_page, total = ::SurvivalsPlayerSearch.new(survival_player_list_params).search

      render json: collection,
        each_serializer: SurvivalPlayerSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    # api :GET, "/survivals_player/:wallet_addr", "Survival details (Authenticaded)"
    # # param_group :survivals_controller_by_user, Docs::V1::ArenasControllerDoc
    # # CAN BE USED BY OTHERS (VIA ADMIN?))
    # def show
    #   wallet_addr = @user_data["publicAddress"] || params[:wallet_addr]

    #   survival_player_params[:filter].merge!({ wallet_addr: wallet_addr })

    #   collection, page, per_page, total = ::SurvivalsPlayerSearch.new(survival_player_params).search

    #   render json: collection,
    #     each_serializer: SurvivalSerializer,
    #     adapter: :json_api,
    #     meta: pagination_dict(page, per_page, total),
    #     status: :ok
    # end

    api :GET, "/survival_player/current_entry", "Gets the last entry for a player"
    # param_group :survivals_controller_by_user, Docs::V1::ArenasControllerDoc
    def current_entry
      entry = SurvivalPlayer.find_by(wallet_addr: @user_data["publicAddress"], survival_id: params[:survival_id].to_i).current_entry

      render json: entry,
        serializer: SurvivalPlayers::EntrySerializer,
        adapter: :json_api,
        status: :ok
    rescue Survivals::EntryNotFound => e
      render json: e.message, status: :not_found
    rescue Mongoid::Errors::DocumentNotFound
      render json: "Survival player not found for this survival", status: :not_found
    rescue => e
      render json: e.message, status: :internal_server_error
    end

    api :POST, "/survival_player", "Create player for a survival (Authenticaded)"
    # param_group :survivals_controller_by_user, Docs::V1::ArenasControllerDoc
    # CAN BE USED BY OTHERS (VIA ADMIN?))
    def create
      # wallet_addr = @user_data.try(:[],"publicAddress") || survival_player_create_params[:wallet_addr]

      survival_player = Survivals::GeneratePlayer.call(@user_data["publicAddress"],
        survival_player_create_params[:survival_id],
        survival_player_create_params[:ticket_id])

      render json: survival_player,
        serializer: SurvivalPlayerSerializer,
        adapter: :json_api,
        status: :ok
    rescue Survivals::TicketNotSpent => e
      render json: e.message, status: :bad_request
    rescue Survivals::PlayerFieldsMissing => e
      render json: e.message, status: :bad_request
    rescue Survivals::MultipleActiveStreak => e
      render json: e.message, status: :bad_request
    rescue => e
      render json: e.message, status: :internal_server_error
    end

    private

    def survival_player_create_params
      params.require(:data).require(:attributes).permit(:survival_id, :ticket_id, :wallet_addr)
    end

    def survival_player_list_params
      params.permit(filter: [:survival_id, :wallet_addr], page: {})
    end

    # def survival_player_params
    #   params.permit(filter: [ :survival_id ], page: {})
    # end
  end
end
