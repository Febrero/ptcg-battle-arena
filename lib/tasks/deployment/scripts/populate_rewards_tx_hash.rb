module AfterParty
  class PopulateRewardsTxHash
    def call
      TicketOffer.where(offered: true).nin(reward_key: [nil, ""]).each do |ticket_offer|        
        reward = Rewards::Reward.find(ticket_offer.reward_key).first
        reward&.update(tx_hashes: [ticket_offer.tx_hash])
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end
end
