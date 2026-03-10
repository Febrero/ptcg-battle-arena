module V1
  class LeaderboardsController < ApplicationController
    include BasicAuth
    before_action :auth_frontend

    api :GET, "/leaderboards/:source/:time_range/:season_survival_arena_playoff", "proxy to leaderboards api"
    def show
      source = params.delete :source
      raise LeaderboardSourceNotAvailable unless ["battle_arena"].include? source

      # @todo put permit parameters as private method
      time_range = params.delete :time_range
      season_survival_arena_playoff = params.delete :season_survival_arena_playoff

      render json:
        LeaderboardsSearch
          .new(
            source,
            time_range,
            season_survival_arena_playoff,
            params.permit(:order, :to_page, filter: %i[key username wallet_addr season arena survival playoff month year], page: %i[page per_page])
          )
          .search
    rescue InternalApiTimeOut, InternalApiForbidden, InternalApiError, InternalApiBadRequest,
      Errno::ECONNREFUSED, InternalApiConnectionRefused => e
      render json: {error: e.message}, status: :service_unavailable
    rescue LeaderboardSourceNotAvailable, Net::HTTPNotFound, InternalApiNotFound => e
      render json: {error: e.message}, status: :not_found
    rescue
      render status: :internal_server_error
    end

    api :GET, "/leaderboards/battle_arena/game_modes/:wallet_addr", "proxy to leaderboards api leaderboards game_modes season"
    def game_modes_profile
      wallet_addr = params[:wallet_addr]
      season_uid = params.dig(:filter, :season)
      if season_uid.nil?
        season = Season.currently_active.first
        season_uid = season&.uid
      end

      render json: LeaderboardsSearch.game_modes_profile(wallet_addr, season_uid).merge({season_info: {uid: season_uid, name: season&.name}})
    rescue InternalApiTimeOut, InternalApiForbidden, InternalApiError, InternalApiBadRequest,
      Errno::ECONNREFUSED, InternalApiConnectionRefused => e
      render json: {error: e.message}, status: :service_unavailable
    rescue LeaderboardSourceNotAvailable, Net::HTTPNotFound, InternalApiNotFound => e
      render json: {error: e.message}, status: :not_found
    rescue
      render status: :internal_server_error
    end
  end
end
