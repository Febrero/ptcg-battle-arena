module V1
  class StandaloneBuildsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::StandaloneBuildsControllerDoc

    before_action :set_standalone_build, only: [:show, :update, :destroy]
    before_action :auth_external_api, only: [:show, :create, :update, :destroy]
    before_action :auth_frontend, only: [:index, :control]
    around_action :use_read_only_databases, only: [:index, :show]

    api :GET, "/standalone_builds", "List of standalone builds (Authenticated)"
    param_group :standalone_builds_controller_index, Docs::V1::StandaloneBuildsControllerDoc
    def index
      collection, page, per_page, total = ::StandaloneBuildsSearch.new(search_params).search
      render json: collection,
        each_serializer: StandaloneBuildSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/standalone_builds/:id", "Standalone build detail (Authenticated)"
    param_group :standalone_builds_controller_show, Docs::V1::StandaloneBuildsControllerDoc
    def show
      if @standalone_build
        render json: @standalone_build,
          serializer: StandaloneBuildSerializer,
          adapter: :json_api,
          status: :ok
      else
        head :not_found
      end
    end

    api :POST, "/standalone_builds", "Create standalone build (Authenticated)"
    param_group :standalone_builds_controller_create, Docs::V1::StandaloneBuildsControllerDoc
    def create
      standalone_build = StandaloneBuild.new(standalone_build_params)
      if standalone_build.save
        render json: standalone_build,
          serializer: StandaloneBuildSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: standalone_build.errors.messages, status: :bad_request
      end
    end

    api :PUT, "/standalone_builds/:id", "Update standalone build (Authenticated)"
    param_group :standalone_builds_controller_update, Docs::V1::StandaloneBuildsControllerDoc
    def update
      if @standalone_build.update(standalone_build_params)
        render json: @standalone_build,
          serializer: StandaloneBuildSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: @standalone_build.errors.messages, status: :bad_request
      end
    end

    api :DELETE, "/standalone_builds/:id", "Delete standalone build (Authenticated)"
    param_group :standalone_builds_controller_destroy, Docs::V1::StandaloneBuildsControllerDoc
    def destroy
      @standalone_build.destroy
      head :no_content
    end

    def control
      version_control = GetBuildVersionControl.call(params[:version])
      render json: version_control, status: :ok
    end

    private

    def set_standalone_build
      @standalone_build = StandaloneBuild.where(id: params[:id]).first
    end

    def standalone_build_params
      params.require(:data).require(:attributes).permit(
        :version,
        :exe_download_url,
        :dmg_download_url,
        :force_update,
        :notes,
        :change_log,
        :visibility
      )
    end

    def search_params
      params.permit(:sort, :page, :per_page, filter: {}, page: {})
    end
  end
end
