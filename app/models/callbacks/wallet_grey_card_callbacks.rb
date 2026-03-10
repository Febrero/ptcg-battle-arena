module Callbacks
  module WalletGreyCardCallbacks
    def before_create(wallet_grey_card)
      Denormalization::DenormalizeGreyCardInfoToWalletGreyCards.call(wallet_grey_card.grey_card, wallet_grey_card)
    end
  end
end
