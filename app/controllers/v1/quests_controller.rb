module V1
  class QuestsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::QuestsControllerDoc

    before_action :set_quest, only: [:show, :update, :destroy, :configs, :current_streak]
    before_action :auth_frontend, only: [:index, :configs, :current_streak]
    before_action :auth_external_api, only: []
    around_action :use_read_only_databases, only: [:index]

    api :GET, "/quests", "List of quests (Authenticaded)"
    param_group :quests_controller_index, Docs::V1::QuestsControllerDoc
    def index
      collection, page, per_page, total = ::QuestsSearch.new(search_params).search

      render json: collection,
        each_serializer: QuestConfigSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/quests/:uid/configs", "List of quests (Authenticaded)"
    param_group :day_prizes, Docs::V1::QuestsControllerDoc
    def configs
      return render json: {error: "Quest not found"}, status: :not_found unless @quest

      render json: [@quest], adapter: :json_api, each_serializer: QuestConfigSerializer
    end

    api :GET, "/quests/:uid/current/:wallet_addr", "get current streak (Authenticaded)"
    param_group :current_streak, Docs::V1::QuestsControllerDoc
    def current_streak
      quest_profile = GameType::QuestProfile.where(wallet_addr: params[:wallet_addr], quest: @quest).first
      if quest_profile
        render json: [quest_profile], adapter: :json_api, each_serializer: QuestProfileCurrentStreakSerializer, status: :ok
      else
        render json: {error: "Quest profile not found"}, status: :not_found
      end
    end

    private

    def set_quest
      @quest = GameType::Quest.where(uid: params[:uid]).first
    end

    def search_params
      params.permit(:sort, filter: [], page: [])
    end
  end
end
