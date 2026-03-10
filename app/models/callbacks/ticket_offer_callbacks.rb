module Callbacks
  module TicketOfferCallbacks
    def before_save(ticket_offer)
      downcase_wallet_addr(ticket_offer)
    end

    def before_create(ticket_offer)
      denormalize_ticket_info_to_ticket_offer(ticket_offer)
    end

    def after_update(ticket_offer)
      update_reward_state(ticket_offer)
    end

    private

    def downcase_wallet_addr(ticket_offer)
      ticket_offer.wallet_addr = ticket_offer.wallet_addr.downcase
    end

    def denormalize_ticket_info_to_ticket_offer(ticket_offer)
      Denormalization::DenormalizeTicketInfoToTicketOffers.call(ticket_offer.ticket, ticket_offer)
    end

    def update_reward_state(ticket_offer)
      return unless ticket_offer.reward_key.present? && ticket_offer.changes.has_key?(:offered)

      reward = Rewards::Reward.find(ticket_offer.reward_key).first
      reward.update(state_event: "deliver", tx_hashes: [ticket_offer.tx_hash])
    end
  end
end
