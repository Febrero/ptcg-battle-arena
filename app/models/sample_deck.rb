class SampleDeck
  include Mongoid::Document
  include Mongoid::Timestamps

  MAX_NAME_CHARACTER_COUNT = 20

  field :type, type: String
  field :stars, type: Integer, default: 0
  field :serial_number, type: Integer
  field :flag_status, type: Boolean, default: true
  field :nfts_count, type: Integer
  field :grey_cards_count, type: Integer
  field :video_ids, type: Array, default: []
  field :grey_card_ids, type: Array, default: []
  field :power, type: Integer

  validate :validate_video_ids
  validate :validate_grey_card_ids
  validate :validate_video_ids
  validate :validate_maximum_repeated_grey_cards
  validate :validate_maximum_deck_size

  def validate_maximum_deck_size
    config = Configs::GetConfig.call
    if video_ids.size + grey_card_ids.size > config[:decks][:rules][:max_cards]
      errors.add(:base, "Maximum nfts per deck reached")
    end
  end

  def validate_grey_card_ids
    grey_card_ids.each do |id|
      errors.add(:grey_card_ids, "Unpermitted grey card ids") unless GreyCard.where(uid: id).first
    end
  end

  def validate_maximum_repeated_grey_cards
    config = Configs::GetConfig.call
    grey_card_ids.each do |id|
      if grey_card_ids.count(id) > config[:decks][:rules][:max_repeated_grey_cards]
        errors.add(:grey_card_ids, "Maximum repeated grey cards reached")
      end
    end
  end

  def validate_video_ids
    videos = FetchVideos.call({options: {disable_pagination: true}})["data"]
    permitted_video_ids = videos.map { |video| video["attributes"]["uid"] }

    video_ids.each do |id|
      errors.add(:video_ids, "Unpermitted video ids") unless permitted_video_ids.include?(id)
    end
  end
end
