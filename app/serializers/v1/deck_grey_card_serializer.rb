module V1
  class DeckGreyCardSerializer < ActiveModel::Serializer
    attributes :uid, :video_id, :position, :power

    def uid
      -1
    end

    def video_id
      object.uid
    end

    def power
      @instance_options[:nfts_power][video_id]
    end
  end
end
