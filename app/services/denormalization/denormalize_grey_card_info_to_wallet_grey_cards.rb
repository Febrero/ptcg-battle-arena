module Denormalization
  class DenormalizeGreyCardInfoToWalletGreyCards < ApplicationService
    def call(grey_card, wallet_grey_card = nil)
      if wallet_grey_card
        if wallet_grey_card.new_record?
          wallet_grey_card.assign_attributes(extract_attributes(grey_card))
        else
          wallet_grey_card.update(extract_attributes(grey_card))
        end
      else
        grey_card.wallet_grey_cards.each do |wallet_grey_card|
          wallet_grey_card.update(extract_attributes(grey_card))
        end
      end
    end

    private

    def extract_attributes(grey_card)
      {
        rarity: grey_card.rarity,
        player_name: grey_card.player_name,
        drop: grey_card.drop,
        drop_slug: grey_card.drop_slug,
        position: grey_card.position,
        defense: grey_card.defense,
        attack: grey_card.attack,
        stamina: grey_card.stamina,
        ball_stopper: grey_card.ball_stopper,
        super_sub: grey_card.super_sub,
        man_mark: grey_card.man_mark,
        enforcer: grey_card.enforcer,
        power: grey_card.power,
        inspire: grey_card.inspire,
        captain: grey_card.captain,
        long_passer: grey_card.long_passer,
        box_to_box: grey_card.box_to_box,
        dribbler: grey_card.dribbler
      }
    end
  end
end
