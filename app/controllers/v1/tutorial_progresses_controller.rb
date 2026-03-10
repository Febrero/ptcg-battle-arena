module V1
  class TutorialProgressesController < ApplicationController
    include BasicAuth
    include PaginationMeta

    prepend_before_action :authenticate_user!, only: :new_step
    before_action :auth_internal_api, only: [:index, :show, :reset_all]
    before_action :auth_frontend, only: :new_step
    before_action :auth_frontend_or_internal_api, only: :reset
    before_action :set_tutorial_progress, only: :show

    api :GET, "/tutorial_progresses", "List of tutorial progresses (Authenticated)"
    def index
      collection, page, per_page, total = ::TutorialProgressesSearch.new(search_params).search

      render json: collection,
        each_serializer: TutorialProgressSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/tutorial_progresses/:id", "Tutorial progress (Authenticated)"
    def show
      if @tutorial_progress
        render json: @tutorial_progress,
          serializer: TutorialProgressSerializer,
          adapter: :json_api,
          status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/tutorial_progresses/new_step", "New tutorial progress step (Authenticated)"
    def new_step
      tutorial_progress = TutorialProgresses::NewStep.call(@user_data["publicAddress"], new_step_params[:step_name])

      if tutorial_progress.valid?
        render json: tutorial_progress,
          serializer: TutorialProgressSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: tutorial_progress.errors.messages, status: :bad_request
      end
    end

    # ! TEMPORARY ENDPOINT USED FOR TESTING PROPOSES
    api :DELETE, "/tutorial_progresses/reset", "Destroy tutorial progress (Authenticated)"
    def reset
      return head :not_found if Rails.env.production? && !internal_api

      wallet_addr = if internal_api
        params[:wallet_addr]
      else
        authenticate_user!
        @user_data["publicAddress"]
      end

      TutorialProgress.where(wallet_addr_downcased: wallet_addr.downcase).first&.destroy
      WalletGreyCard.where(wallet_addr: Eth::Address.new(wallet_addr).checksummed).destroy_all
      Deck.where(wallet_addr: Eth::Address.new(wallet_addr).checksummed).destroy_all

      head :ok
    end

    # ! TEMPORARY ENDPOINT USED FOR TESTING PROPOSES
    api :DELETE, "/tutorial_progresses/reset_all", "Destroy all tutorial progresses (Authenticated)"
    def reset_all
      return head :not_found if Rails.env.production? && !internal_api

      TutorialProgress.destroy_all
      WalletGreyCard.destroy_all
      Deck.destroy_all

      head :ok
    end

    private

    def set_tutorial_progress
      @tutorial_progress = TutorialProgress.where(id: params[:id]).first
    end

    def new_step_params
      params.permit(:step_name)
    end

    def search_params
      params.permit(:sort, page: [], filter: [])
    end
  end
end
