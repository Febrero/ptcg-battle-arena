module V1
  class CardOffersController < ApplicationController
    include PaginationMeta
    include BasicAuth

    before_action :set_card_offer, only: [:show, :update]
    before_action :auth_internal_api, only: [:index, :show, :create, :update]
    around_action :use_read_only_databases, only: [:index, :show]

    api :GET, "/card_offers", "Card Offers Index"
    def index
      collection, page, per_page, total = ::CardOffersSearch.new(params).search
      render json: collection,
        each_serializer: CardOfferSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/card_offers/:id", "Show Card Offers"
    def show
      if @card_offer
        render json: @card_offer, serializer: CardOfferSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/card_offers", "Create Card Offers"
    def create
      CreateCardOffers.call(card_offer_params)

      head :ok
    rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::Validations, InvalidCardOfferParams => e
      Airbrake.notify("INVALID CARD OFFER PARAMS", {
        class: "CreateCardOffers",
        offer_detail: params[:offer_detail],
        wallet_addr: params[:wallet_addr],
        reward_key: params[:reward_key],
        exception_message: e.message
      })

      head :bad_request
    end

    private

    def set_card_offer
      @card_offer = CardOffer.where(id: params[:id]).first
    end

    def card_offer_params
      params.permit(
        :wallet_addr,
        :quantity,
        :card_type,
        :reward_key,
        :source,
        offer_detail: {}
      )
    end
  end
end
