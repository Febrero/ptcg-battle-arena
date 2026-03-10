module V1
  module PlayerProfile
    class UserActivitiesController < ApplicationController
      include BasicAuth
      include PaginationMeta

      prepend_before_action :authenticate_user!, only: :user
      before_action :auth_frontend
      before_action :set_user_activity, only: :show

      def user
        scope = UserActivity.where(wallet_addr: @user_data["publicAddress"])

        collection, page, per_page, total = ::UserActivitiesSearch.new(search_params, scope).search

        render json: collection,
          each_serializer: UserActivitySerializer,
          adapter: :json_api,
          meta: pagination_dict(page, per_page, total),
          status: :ok
      end

      def show
        if @user_activity.present?
          render json: @user_activity,
            serializer: UserActivityDetailSerializer,
            adapter: :json_api,
            status: :ok
        else
          head :not_found
        end
      rescue => e
        Airbrake.notify(e)
        render status: :internal_server_error
      end

      private

      def set_user_activity
        @user_activity = UserActivity.where(id: params[:id]).first
      end

      def search_params
        params.permit(:sort, filter: {}, page: {})
      end
    end
  end
end
