module V1
  class DecksController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::DecksControllerDoc

    prepend_before_action :user_or_external_api_auth, only: [:index, :show]
    prepend_before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :auth_external_api, only: [:list]
    before_action :auth_frontend, only: [:index, :show, :create, :update, :destroy]
    before_action :set_deck, only: [:show, :destroy, :update]
    around_action :use_read_only_databases, only: [:index, :show, :list]

    # TODO USE index on admin instead of /decks/list
    # ! This action is temporary while the migration below is not done
    api :GET, "/decks/list", "List of all decks"
    param_group :decks_controller_list, Docs::V1::DecksControllerDoc
    def list
      collection, page, per_page, total = ::DecksSearch.new(params).search
      render json: collection,
        each_serializer: DeckCollectionSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    # ! This action will be available to admin after FBA migration to action: user
    api :GET, "/decks", "List of user's decks (Authenticated)"
    param_group :decks_controller_index, Docs::V1::DecksControllerDoc
    def index
      if external_api
        collection, page, per_page, total = ::DecksSearch.new(params).search
        render json: collection,
          each_serializer: DeckCollectionSerializer,
          adapter: :json_api,
          meta: pagination_dict(page, per_page, total),
          status: :ok
      else
        decks = Deck.where(wallet_addr: @user_data["publicAddress"])
        render json: decks,
          each_serializer: DeckSerializer,
          adapter: :json_api,
          status: :ok
      end
    end

    # ! This action will be available to admin after FBA migration to action: user
    api :GET, "/decks/:id", "List of deck nft's"
    param_group :decks_controller_show, Docs::V1::DecksControllerDoc
    def show
      render json: @deck,
        serializer: DeckCollectionSerializer,
        adapter: :json_api,
        status: :ok
    end

    api :POST, "/decks", "Create deck (Authenticaded)"
    param_group :decks_controller_create, Docs::V1::DecksControllerDoc
    def create
      deck = Deck.new(deck_params)
      if deck.save
        render json: deck, serializer: DeckCollectionSerializer, adapter: :json_api, status: :ok
      else
        render json: deck.errors.messages, status: :bad_request
      end
    end

    api :PUT, "/decks/:id", "Update deck (Authenticaded)"
    param_group :decks_controller_update, Docs::V1::DecksControllerDoc
    def update
      if @deck.update(deck_params)
        render json: @deck, serializer: DeckCollectionSerializer, adapter: :json_api, status: :ok
      else
        render json: @deck.errors.messages, status: :bad_request
      end
    end

    api :DELETE, "/decks/:id", "delete decks (Authenticaded)"
    param_group :decks_controller_destroy, Docs::V1::DecksControllerDoc
    def destroy
      if @deck.destroy
        render json: {success: true}, status: :ok
      else
        render json: @deck.errors.messages, status: :bad_request
      end
    end

    private

    def set_deck
      @deck =
        if external_api || internal_api
          Deck.where(id: params[:id]).first
        else
          Deck.where(id: params[:id], wallet_addr: @user_data["publicAddress"]).first
        end
    end

    def deck_params
      params.require(:deck).permit(:id, :name, :wallet_addr, nft_ids: [], grey_card_ids: [])
    end
  end
end
