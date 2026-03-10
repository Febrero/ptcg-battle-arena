class FetchDeckFormationFlag < ApplicationService
  attr_accessor :goalkeeper_count

  def call(deck)
    check_formation_with_count(deck) && check_by_goalkeeper && check_deck_moments_rarities(deck)
  end

  private

  def check_deck_moments_rarities(deck)
    config = Configs::GetConfig.call
    stars_config = config[:decks][:stars_config].find { |item| item[:stars] == deck.stars }

    deck.grey_card_ids.size <= stars_config[:limits][:starter]
  end

  def check_formation_with_count(deck)
    set_formation_positions_count(deck)
    config = Configs::GetConfig.call
    total_count = deck.nfts_count + deck.grey_cards_count
    bottom_check = total_count >= config[:decks][:rules][:min_cards]
    top_check = total_count <= config[:decks][:rules][:max_cards]

    bottom_check && top_check
  end

  def check_by_goalkeeper
    config = Configs::GetConfig.call
    @goalkeeper_count >= config[:decks][:rules][:min_gks]
  end

  # Setting all the counts with respect to player/card type.
  def set_formation_positions_count(deck)
    @goalkeeper_count = 0
    deck.nfts.each do |nft|
      @goalkeeper_count += 1 if nft.position == Nft::POSITION_GOALKEEPER
    end

    deck.grey_card_ids.each do |id|
      @goalkeeper_count += 1 if GreyCard.where(uid: id).first.position == Nft::POSITION_GOALKEEPER
    end
  end
end
