class PlayerProfile::Stats::Decks < ApplicationService
  def call(wallet_addr)
    (1..5).to_a.each_with_object({}) do |stars, hash|
      hash[stars.to_s] = Deck.where(wallet_addr: wallet_addr, stars: stars).count
    end
  end
end
