module V1
  class SeasonSerializer < ActiveModel::Serializer
    attributes :uid,
      :name,
      :start_date,
      :end_date,
      :active
  end
end
