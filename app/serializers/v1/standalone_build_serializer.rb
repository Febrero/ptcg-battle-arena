module V1
  class StandaloneBuildSerializer < ActiveModel::Serializer
    attributes :version,
      :exe_download_url,
      :dmg_download_url,
      :force_update,
      :notes,
      :change_log,
      :visibility,
      :created_at
  end
end
