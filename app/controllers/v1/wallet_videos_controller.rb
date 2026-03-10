# frozen_string_literal: true

module V1
  class WalletVideosController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::WalletVideosControllerDoc

    prepend_before_action :authenticate_user!
    before_action :auth_frontend

    api :GET, "wallet_videos/wallet_collection", "Get filtered user wallet videos (Authenticaded)"
    param_group :wallet_videos_controller_wallet_collection, Docs::V1::WalletVideosControllerDoc
    def wallet_collection
      params[:filter] = {} unless params[:filter].present?
      params[:page] = {} unless params[:page].present?

      params[:filter][:wallet_addr] = @user_data["publicAddress"]
      params[:filter][:nft_uids_in_wallet] = true
      params[:page][:per_page] = 24 unless params[:page][:per_page].present?
      params[:sort] = params[:filter][:order] if params[:filter][:order]
      params[:lite] = true

      response = InternalApi.new.get("marketplace", request_uri: "/wallet_videos", query: search_params)

      render json: response.json, status: response.code
    end

    def search_params
      params.permit(:sort, :lite, :order, page: {}, filter: {})
    end
  end
end
