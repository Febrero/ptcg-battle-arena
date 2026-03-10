module GameType
  class Quest
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Pagination

    field :uid, type: Integer
    field :type, type: String

    field :active, type: Boolean

    field :config, type: Array
    field :summary, type: Hash

    field :home_background_image_url, type: String
    field :home_foreground_image_url, type: String

    # has_many :profiles, class_name: "GameType::QuestProfile"

    has_many :profiles, class_name: "GameType::QuestProfile", foreign_key: :quest_id, primary_key: :uid

    index({uid: 1}, {name: "uid_index", background: true})

    validates :uid, presence: true, uniqueness: true
    validates :type, presence: true

    def rewards_day(day)
      config[day - 1]
    end

    def summarize(from_day = nil, until_day = nil)
      summary = {
        xp: 0,
        fevr: 0,
        nft: {},
        ticket: {},
        pack: {}
      }

      from_index = from_day ? (from_day - 1) : 0
      to_index = until_day ? (until_day - 1) : (config.count - 1)
      config[from_index..to_index]&.each_with_index do |rewards, index|
        summary[:xp] += rewards[:xp] if rewards[:xp]
        summary[:fevr] += rewards[:fevr] if rewards[:fevr]

        [:nft, :ticket, :pack].each do |reward_type|
          rewards[reward_type]&.each do |type, count|
            summary[reward_type][type] ||= 0
            summary[reward_type][type] += count
          end
        end
      end
      summary
    end

    def hash_prize(type, value, subtype_value = nil)
      hash = {
        type: type,
        amount: value
      }

      hash[:subtype] = subtype_value.to_s if subtype_value
      hash
    end

    def serializer
      serializer = []
      config.each_with_index do |rewards, index|
        day = index + 1
        prizes = []
        prizes << hash_prize("xp", rewards[:xp]) if rewards[:xp]
        prizes << hash_prize("fevr", rewards[:fevr]) if rewards[:fevr]

        [:nft, :ticket, :pack, :avatar].each do |reward_type|
          rewards[reward_type]&.each do |type, count|
            if reward_type == :ticket
              ticket = GameMode.ticket_from_uid(type.to_i)
              type = ticket.name
            end

            prizes << hash_prize(reward_type.to_s, count, type)
          end
        end

        serializer << {level: day, prizes: prizes}
      end
      serializer
    end
  end
end
