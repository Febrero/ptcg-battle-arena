module V1
  class ArticlesController < ApplicationController
    include BasicAuth
    include PaginationMeta

    before_action :auth_frontend
    before_action :set_article, only: %i[show update destroy]
    around_action :use_read_only_databases, only: [:index, :show]

    def index
      collection, page, per_page, total = ArticlesSearch.new(search_params, Article).search

      render json: collection,
        each_serializer: ArticleSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    def active
      active_articles, page, per_page, total = ArticlesSearch.new({}).search

      render json: active_articles,
        each_serializer: ArticleSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    def show
      if @article
        render json: @article,
          serializer: ArticleSerializer,
          adapter: :json_api,
          status: :ok
      else
        head :not_found
      end
    end

    def create
      article = Article.new(article_params)
      article.position_order = 1 unless article.position_order.present?

      if article.save
        render json: article,
          serializer: ArticleSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: article,
          serializer: ActiveModel::Serializer::ErrorSerializer,
          adapter: :json_api,
          status: :unprocessable_entity
      end
    end

    def update
      fixed_params = article_params
      fixed_params[:position_order] = 1 unless fixed_params[:position_order].present?

      if @article.update(fixed_params)
        render json: @article,
          serializer: ArticleSerializer,
          adapter: :json_api,
          status: :ok
      else
        render json: @article,
          serializer: ActiveModel::Serializer::ErrorSerializer,
          adapter: :json_api,
          status: :unprocessable_entity
      end
    end

    def destroy
      @article.destroy
      head :no_content
    end

    private

    def set_article
      @article = Article.where(uid: params[:uid]).first
    end

    def search_params
      params.permit(
        :sort,
        filter: [:active, :start_date, :gte_start_date, :end_date, :lte_end_date],
        page: [:page, :per_page]
      )
    end

    def article_params
      params.require(:data).require(:attributes).permit(
        :title,
        :subtitle,
        :description,
        :active,
        :start_date,
        :end_date,
        :position_order,
        :cover_image_url,
        :url
      )
    end
  end
end
