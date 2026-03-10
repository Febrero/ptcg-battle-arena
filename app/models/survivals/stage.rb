module Survivals
  class Stage
    include Mongoid::Document

    field :level, type: Integer
    field :prize_amount, type: Float
    field :prize_type, type: String
    field :prize_image_url, type: String

    embedded_in :survival, class_name: "Survival"
  end
end
