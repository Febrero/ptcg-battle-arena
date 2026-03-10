module V1
  class TokensController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :auth_frontend

    def index
      json_response = FetchTokens.call(search_params)

      json_response["data"].map! do |item|
        item["attributes"] = {
          "name" => item["attributes"]["name"],
          "address" => item["attributes"]["address"],
          "image_url" => item["attributes"]["image_url"]
        }
      end

      render json: json_response, status: :ok
    end

    private

    def search_params
      params.permit(
        :sort,
        page: {},
        filters: {},
        options: {}
      )
    end
  end
end
