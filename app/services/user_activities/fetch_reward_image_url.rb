module UserActivities
  class FetchRewardImageUrl < ApplicationService
    def call(reward)
      send("#{reward.reward_type.downcase}_image", reward)
    end

    private

    def fevr_image(reward)
      case reward.value
      when (0...50000)
        Rails.application.config.rewards_history_images[:fevr][:image_1]
      when (50000...200000)
        Rails.application.config.rewards_history_images[:fevr][:image_2]
      when (200000...500000)
        Rails.application.config.rewards_history_images[:fevr][:image_3]
      else
        Rails.application.config.rewards_history_images[:fevr][:image_4]
      end
    end

    def bnb_image(reward)
      case reward.value
      when (0...0.5)
        Rails.application.config.rewards_history_images[:bnb][:image_1]
      when (0.5...2)
        Rails.application.config.rewards_history_images[:bnb][:image_2]
      when (2...5)
        Rails.application.config.rewards_history_images[:bnb][:image_3]
      else
        Rails.application.config.rewards_history_images[:bnb][:image_4]
      end
    end

    def eth_image(reward)
      case reward.value
      when (0...5)
        Rails.application.config.rewards_history_images[:eth][:image_1]
      when (0.5...2)
        Rails.application.config.rewards_history_images[:eth][:image_2]
      when (2...5)
        Rails.application.config.rewards_history_images[:eth][:image_3]
      else
        Rails.application.config.rewards_history_images[:eth][:image_4]
      end
    end

    def usdt_image(reward)
      case reward.value
      when (0...100)
        Rails.application.config.rewards_history_images[:usdt][:image_1]
      when (100...500)
        Rails.application.config.rewards_history_images[:usdt][:image_2]
      when (500...1000)
        Rails.application.config.rewards_history_images[:usdt][:image_3]
      else
        Rails.application.config.rewards_history_images[:usdt][:image_4]
      end
    end

    def xp_image(reward)
      case reward.value
      when (0...40)
        Rails.application.config.rewards_history_images[:xp][:image_1]
      when (40...50)
        Rails.application.config.rewards_history_images[:xp][:image_2]
      when (50...75)
        Rails.application.config.rewards_history_images[:xp][:image_3]
      when (75...100)
        Rails.application.config.rewards_history_images[:xp][:image_4]
      when (100...125)
        Rails.application.config.rewards_history_images[:xp][:image_5]
      when (125...150)
        Rails.application.config.rewards_history_images[:xp][:image_6]
      else
        Rails.application.config.rewards_history_images[:xp][:image_7]
      end
    end

    def ticket_image(reward)
      # ! TODO: Temporary fix while offer_detail is not populated on ticket rewards
      if reward.offer_detail.nil?
        return Rails.application.config.rewards_history_images[:ticket][:image_1]
      end

      ticket = Ticket.where(
        bc_ticket_id: reward.offer_detail["bc_ticket_id"],
        ticket_factory_contract_address: reward.offer_detail["ticket_factory_contract_address"]
      ).first

      case ticket.erc20_name.downcase
      when "fevr"
        Rails.application.config.rewards_history_images[:ticket][:image_1]
      when "bnb"
        Rails.application.config.rewards_history_images[:ticket][:image_2]
      when "eth"
        Rails.application.config.rewards_history_images[:ticket][:image_3]
      when "btc"
        Rails.application.config.rewards_history_images[:ticket][:image_4]
      end
    end

    def avatar_image(reward)
      Rails.application.config.rewards_history_images[:avatar][:image_1]
    end

    def nft_image(reward)
      case reward.reward_subtype.downcase
      when "common"
        Rails.application.config.rewards_history_images[:nft][:image_1]
      when "special"
        Rails.application.config.rewards_history_images[:nft][:image_2]
      when "epic"
        Rails.application.config.rewards_history_images[:nft][:image_3]
      when "legendary"
        Rails.application.config.rewards_history_images[:nft][:image_4]
      when "unique"
        Rails.application.config.rewards_history_images[:nft][:image_5]
      else
        # when reward_subtype is nil fallback to fevr ticket
        Rails.application.config.rewards_history_images[:nft][:image_1]
      end
    end

    def pack_image(reward)
      case reward.reward_subtype.downcase
      when "basic"
        Rails.application.config.rewards_history_images[:pack][:image_1]
      when "rare"
        Rails.application.config.rewards_history_images[:pack][:image_2]
      else
        # when reward_subtype is nil fallback to basic pack
        Rails.application.config.rewards_history_images[:pack][:image_1]
      end
    end
  end
end
