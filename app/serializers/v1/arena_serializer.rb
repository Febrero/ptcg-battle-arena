module V1
  class ArenaSerializer < GameModeSerializer
    attributes :xp_info

    def xp_info
      ActiveModel::Serializer::CollectionSerializer.new(RewardsConfig.all, {serializer: RewardsConfigSerializer})
    end
  end
end
