module V1
  class TopMomentsController < ApplicationController
    include BasicAuth
    include Docs::V1::TopMomentsControllerDoc
    prepend_before_action :authenticate_user!, only: %i[show]

    api :GET, "/top_moments", "Get Top moments by wallet (Authenticaded)"
    param_group :top_moments_controller_show, Docs::V1::TopMomentsControllerDoc
    def show
      render json: NftStats::GenerateTopMoments.call(@user_data["publicAddress"]), status: :ok
    end
  end
end
