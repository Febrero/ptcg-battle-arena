# frozen_string_literal: true

class SyncUserCardsJob
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 3

  def perform(ptcg_user_id, card_ids)
    return if card_ids.blank?

    # Remove existing wallet grey cards for this user
    WalletGreyCard.where(ptcg_user_id: ptcg_user_id).destroy_all

    # Map each card_id to a grey card and create WalletGreyCard
    card_ids.each do |card_id|
      grey_card = GreyCard.where(uid: card_id).first
      next unless grey_card

      WalletGreyCard.find_or_create_by(
        ptcg_user_id: ptcg_user_id,
        grey_card_id: grey_card.id.to_s
      )
    end
  end
end
