class RemoveNftFromDecks < ApplicationService
  def call(nft_id, wallet_addr = nil)
    nft_id = nft_id.to_i

    Deck.in(nft_ids: nft_id).not(wallet_addr: wallet_addr).each do |deck|
      deck.pull(nft_ids: nft_id)
      deck.save
    end
  end
end
