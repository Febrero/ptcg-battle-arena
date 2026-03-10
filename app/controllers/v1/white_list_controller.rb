module V1
  class WhiteListController < ApplicationController
    include BasicAuth
    include Docs::V1::WhiteListControllerDoc

    before_action :auth_frontend

    api :GET, "/white_list/:address", "Check if wallet is white listed (Authenticated)"
    param_group :white_list_controller_show, Docs::V1::WhiteListControllerDoc
    def show
      res = GetWalletWhiteListPresence.call(white_list_params[:address])
      if res.code.to_i == 200
        render json: res.body,
          status: :ok
      else
        render status: :not_found
      end
    end

    private

    def white_list_params
      params.permit(:address)
    end
  end
end
