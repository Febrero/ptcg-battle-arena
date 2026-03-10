module V1
  class QuestStreaksController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :set_quest_streak, only: [:show, :update]
    before_action :auth_internal_api

    api :GET, "/quest_streaks", "List of quests streaks (Authenticaded)"
    def index
      collection, page, per_page, total = ::QuestStreaksSearch.new(search_params).search

      render json: collection,
        each_serializer: QuestStreakSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    private

    def search_params
      params.permit(:sort, filter: {}, page: {})
    end
  end
end
