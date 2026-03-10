module V1
  class GreyCardsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::GreyCardsControllerDoc

    before_action :auth_frontend

    api :GET, "/grey_cards", "Grey Cards video info index (Authenticated)"
    param_group :grey_cards_controller_index, Docs::V1::GreyCardsControllerDoc
    def index
      render json: GreyCard.all,
        each_serializer: GreyCardSerializer,
        status: :ok
    end
  end
end
