module V1
  module Playoffs
    class PrizeConfigsController < ApplicationController
      include BasicAuth
      include PaginationMeta

      before_action :auth_external_api
      around_action :use_read_only_databases, only: [:index, :show]

      def index
        collection, page, per_page, total = ::PrizeConfigsSearch.new(search_params).search

        render json: collection,
          each_serializer: ::V1::PrizeConfigsSerializer,
          adapter: :json_api,
          meta: pagination_dict(page, per_page, total),
          status: :ok
      end

      private

      def search_params
        params.permit(:order, filter: [:name, :active], page: [:page, :per_page])
      end
    end
  end
end
