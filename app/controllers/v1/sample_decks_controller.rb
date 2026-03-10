module V1
  class SampleDecksController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::SampleDecksControllerDoc

    prepend_before_action :authenticate_user!, only: [:show]
    before_action :auth_external_api, only: [:show]
    around_action :use_read_only_databases, only: [:show]

    api :GET, "/sample_decks/:stars", "Sample decks (Authenticated)"
    param_group :sample_decks_controller_show, Docs::V1::SampleDecksControllerDoc
    def show
      sample_deck = SampleDeck.where(stars: params[:stars].to_i).first
      if sample_deck
        render json: sample_deck,
          serializer: SampleDeckSerializer,
          adapter: :json_api,
          status: :ok
      else
        render status: :not_found
      end
    end

    private

    def sample_deck_params
      params.require(:stars)
    end
  end
end
