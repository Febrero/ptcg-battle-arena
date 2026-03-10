module Callbacks
  module SampleDeckCallbacks
    def before_save(sample_deck)
      return if sample_deck.errors.present?

      update_nfts_count(sample_deck)
      update_grey_cards_count(sample_deck)
      update_deck_power(sample_deck)
      update_deck_stars(sample_deck)
    end

    private

    def update_nfts_count(sample_deck)
      sample_deck.nfts_count = sample_deck.video_ids.count
    end

    def update_grey_cards_count(sample_deck)
      sample_deck.grey_cards_count = sample_deck.grey_card_ids.count
    end

    def update_deck_power(sample_deck)
      videos = FetchVideos.call({options: {disable_pagination: true}})["data"]

      grey_cards_power = sample_deck.grey_card_ids.map { |uid| GreyCard.where(uid: uid).first.power }.sum
      nfts_power = sample_deck.video_ids.map { |uid| videos.find { |video| video["attributes"]["uid"] == uid }["attributes"]["power"] }.sum
      sample_deck.power = nfts_power + grey_cards_power
    end

    # Sets the stars for a deck based on its power
    #
    # @note Runs on save (on creation defaults to 0)
    # @note Iterates over the power upper tiers (defined on the deck) and when it founds a
    #       tier higher than it's power, calculates the star based on the index of the tier
    # @note Defaults to 5 stars (since there is no power limit for these kind of decks)
    #
    # @params [Deck] the deck instance goin got be saved
    #
    def update_deck_stars(sample_deck)
      config = Configs::GetConfig.call
      sample_deck.stars = 5

      config[:decks][:power_upper_tiers].each_with_index do |upper_tier, idx|
        if sample_deck.power < upper_tier
          sample_deck.stars = (idx + 1)
          break
        end
      end
    end
  end
end
