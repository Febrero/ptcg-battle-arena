module V1
  class ProfilesController < ApplicationController
    include BasicAuth

    prepend_before_action :authenticate_user!, except: %i[confirm_email leaderboards_info ban_info]
    before_action :auth_frontend, only: %i[show update validate confirm_email leaderboards_info ban_info]

    api :GET, "/profiles/:wallet_addr", "Get profile per wallet (Authenticaded)"
    def show
      profile, status_code = Profile::Fetch.call(@user_data["publicAddress"], request.headers["Authorization"], profile_view[:default_view])

      render json: profile, status: status_code
    end

    def update
      response = Profile::Update.call(
        @user_data["publicAddress"],
        profile_restricted_params,
        request.headers["Authorization"]
      )
      data = begin
        JSON.parse(response.body)
      rescue
        nil
      end
      render json: data, status: response.code
    end

    def validate
      response = Profile::Validate.call(
        profile_restricted_params,
        request.headers["Authorization"]
      )
      data = begin
        JSON.parse(response.body)
      rescue
        nil
      end
      render json: data, status: response.code
    end

    def confirm_email
      response = Profile::ConfirmEmail.call(
        profile_restricted_params
      )
      data = begin
        JSON.parse(response.body)
      rescue
        nil
      end
      render json: data, status: response.code
    end

    api :GET, "/profiles/leaderboards_info", "proxy to leaderboards api"
    def leaderboards_info
      render json: JSON.parse(
        ProfileLeaderboardsInfoSearch
        .new(params.permit(:wallets))
        .search
      )
    rescue Errno::ECONNREFUSED, Net::HTTPRequestTimeout
      render status: :service_unavailable
    rescue Net::HTTPNotFound
      render status: :not_found
    rescue
      render status: :internal_server_error
    end

    def ban_info
      render json: CheckBanPeriod.call(params[:wallet]), status: :ok
    rescue
      render status: :internal_server_error
    end

    private

    def profile_view
      params.permit(
        :default_view
      )
    end

    def profile_restricted_params
      params.require(:profile).permit(
        :username,
        :email,
        :avatar_id,
        :accepted_newsletters,
        :accepted_terms_and_conditions,
        :country_code
      )
    end

    def get_profile
      HTTParty.get(
        "#{Rails.application.config.nft_api_base_url}/profiles/#{@user_data["publicAddress"]}",
        headers: {
          Authorization: request.headers["Authorization"],
          "X-RealFevr-Token": Rails.application.config.nfts_external_api_key
        }
      )
    end
  end
end
