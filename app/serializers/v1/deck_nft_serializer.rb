module V1
  class DeckNftSerializer < ActiveModel::Serializer
    attributes :uid, :video_id, :position, :power

    def power
      @instance_options[:nfts_power][object.video_id]
    end
  end
end
