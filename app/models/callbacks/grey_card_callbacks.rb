module Callbacks
  module GreyCardCallbacks
    def after_update(grey_card)
      Denormalization::DenormalizeGreyCardInfoToWalletGreyCards.call(grey_card)
    end
  end
end
