module V1
  class SplashScreensController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :auth_internal_api
    before_action :set_splash_screen, only: [:show, :update, :destroy]

    api :GET, "/splash_screens", "List of splash screens (Authenticated)"
    def index
      collection, page, per_page, total = ::SplashScreensSearch.new(search_params).search

      render json: collection,
        each_serializer: SplashScreenSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/splash_screens/:id", "Show splash screen (Authenticated)"
    def show
      if @splash_screen
        render json: @splash_screen, serializer: SplashScreenSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/splash_screen", "Create splash screen (Authenticaded)"
    def create
      splash_screen = SplashScreen.new(splash_screen_params)
      if splash_screen.save
        render json: splash_screen, serializer: SplashScreenSerializer, adapter: :json_api, status: :ok
      else
        render json: splash_screen.errors.messages, status: :bad_request
      end
    end

    api :PUT, "/splash_screen/:id", "Update splash screen (Authenticated)"
    def update
      if @splash_screen.update(splash_screen_params)
        render json: @splash_screen, serializer: SplashScreenSerializer, adapter: :json_api, status: :ok
      else
        render json: @splash_screen.errors.messages, status: :bad_request
      end
    end

    api :DELETE, "/splash_screen/:id", "Delete splash screen (Authenticaded)"
    def destroy
      @splash_screen.destroy
      head :no_content
    end

    private

    def set_splash_screen
      @splash_screen = SplashScreen.where(id: params[:id]).first
    end

    def splash_screen_params
      params.require(:data).require(:attributes).permit(
        :name,
        :image_url,
        :active
      )
    end

    def search_params
      params.permit(:page, :per_page)
    end
  end
end
