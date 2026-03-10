module V1
  class ArticleSerializer < ActiveModel::Serializer
    attributes :uid,
      :title,
      :subtitle,
      :cover_image_url,
      :description,
      :url,
      :active,
      :start_date,
      :end_date,
      :position_order,
      :created_at,
      :updated_at
  end
end
