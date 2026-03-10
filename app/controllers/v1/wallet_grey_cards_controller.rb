module V1
  class WalletGreyCardsController < ApplicationController
    include BasicAuth
    include PaginationMeta

    prepend_before_action :authenticate_user!, only: [:wallet_collection]
    before_action :auth_frontend, only: :wallet_collection
    before_action :auth_internal_api, only: %i[index show]
    before_action :set_wallet_grey_card, only: :show
    around_action :use_read_only_databases, only: [:index, :show, :wallet_collection]

    api :GET, "/wallet_grey_cards", "List of wallet grey cards"
    def index
      params[:filter] = {} unless params[:filter].present?
      params[:sort] = params[:filter][:order] if params[:filter][:order]

      collection, page, per_page, total = ::WalletGreyCardsSearch.new(search_params).search

      render json: collection,
        each_serializer: WalletGreyCardSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/wallet_grey_cards/:id", "Show wallet grey cards"
    def show
      if @wallet_grey_card
        render json: @wallet_grey_card, serializer: WalletGreyCardSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :GET, "wallet_grey_cards/wallet_collection", "Get filtered user wallet grey cards (Authenticated)"

    def wallet_collection
      params[:filter] = {} if params[:filter].nil?
      params[:filter][:wallet_addr] = @user_data["publicAddress"]
      params[:sort] = params[:filter][:order] if params[:filter][:order]

      collection, page, per_page, total = ::WalletGreyCardsSearch.new(search_params).search

      render json: collection,
        each_serializer: WalletGreyCardSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    private

    def set_wallet_grey_card
      @wallet_grey_card = WalletGreyCard.where(id: params[:id]).first
    end

    def search_params
      params.permit(
        :id,
        :wallet_addr,
        :rarity,
        :position,
        :grey_card_id,
        :ball_stopper,
        :super_sub,
        :enforcer,
        :man_mark,
        :inspire,
        :captain,
        :long_passer,
        :box_to_box,
        :dribbler,
        :sort,
        page: {},
        filter: {}
      )
    end
  end
end
