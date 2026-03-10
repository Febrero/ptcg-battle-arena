require "httparty"

module Callbacks
  module DeckCallbacks
    def before_save(deck)
      return if deck.errors.present?

      deck.flag_status = ::FetchDeckFormationFlag.call(deck)
      deck.video_ids = update_deck_video_ids(deck)
    end

    def before_validation(deck)
      remove_duplicated_nfts(deck)
      remove_duplicated_grey_cards(deck)
      remove_invalid_nft_ids(deck)
      remove_invalid_grey_card_ids(deck)
      remove_invalid_nft_ids(deck)
      update_nfts_count(deck)
      update_grey_cards_count(deck)
      update_deck_power(deck)
      update_deck_stars(deck)
    end

    def after_create(deck)
      publish_deck_create_event(deck)
    end

    def after_update(deck)
      publish_deck_update_event(deck)
    end

    private

    def update_deck_video_ids(deck)
      nfts = Nft.search(deck.nft_ids, deck.wallet_addr.downcase)
      deck.video_ids = nfts.map(&:video_id).uniq
    end

    # Remove invalid grey cards ids from this deck
    #
    # @note Extra validation for when invalid information is passed to the model (probably from the FE)
    #
    def remove_invalid_grey_card_ids(deck)
      owned_grey_card_ids = WalletGreyCard.where(wallet_addr: deck.wallet_addr).distinct(:grey_card_id)

      deck.grey_card_ids = deck.grey_card_ids & owned_grey_card_ids
    end

    # Remove invalid nfts ids from this deck
    #
    # @note Extra validation for when invalid information is passed to the model (probably from the FE)
    #
    def remove_invalid_nft_ids(deck)
      user_nfts = CheckNftsOwnership.call(deck.wallet_addr, deck.nft_ids)
      deck.nft_ids = begin
        user_nfts.response["valid"]
      rescue
        []
      end
    end

    def remove_duplicated_grey_cards(deck)
      deck.grey_card_ids.uniq!
    end

    def remove_duplicated_nfts(deck)
      deck.nft_ids.uniq!
    end

    def update_nfts_count(deck)
      deck.nfts_count = deck.nft_ids.count
    end

    def update_grey_cards_count(deck)
      deck.grey_cards_count = deck.grey_card_ids.size
    end

    def update_deck_power(deck)
      videos = FetchVideos.call({options: {disable_pagination: true}})["data"]
      grey_cards_power = deck.grey_card_ids.map { |uid| GreyCard.where(uid: uid).first.power }.sum
      nfts_power = deck.nfts.map(&:video_id).map { |uid| videos.find { |video| video["attributes"]["uid"] == uid }["attributes"]["power"].to_i }.sum
      deck.power = nfts_power + grey_cards_power
    end

    # Sets the stars for a deck based on its power
    #
    # @note Only runs on update (on creation defaults to 0)
    # @note Iterates over the power upper tiers (defined on the deck) and when it founds a
    #       tier higher than it's power, calculates the star based on the index of the tier
    # @note Defaults to 5 stars (since there is no power limit for these kind of decks)
    #
    # @params [Deck] the deck instance goin got be saved
    #
    def update_deck_stars(deck)
      config = Configs::GetConfig.call
      deck.stars = 5
      config[:decks][:power_upper_tiers].each_with_index do |upper_tier, idx|
        if deck.power <= upper_tier
          deck.stars = (idx + 1)
          break
        end
      end

      videos = FetchVideos.call({options: {disable_pagination: true}})["data"]

      deck_rarities = deck.nfts.map(&:video_id).map { |uid| videos.find { |video| video["attributes"]["uid"] == uid }["attributes"]["rarity"] }
      stars_config = config[:decks][:stars_config].select do |item|
        result = true

        item[:limits].except(:starter).each_pair do |rarity, max|
          result = false if deck_rarities.count(rarity.capitalize.to_s) > max
        end

        result
      end

      stars_config.sort_by! { |item| item[:stars] }

      deck.stars = stars_config.first[:stars] if stars_config.first[:stars] > deck.stars
    end

    def publish_deck_create_event(deck)
      PublishMessageToRabbitmqTopic.call(
        V1::DeckSerializer.new(deck).to_json,
        "battle_arena_events",
        "deck.create"
      )
    end

    def publish_deck_update_event(deck)
      PublishMessageToRabbitmqTopic.call(
        V1::DeckSerializer.new(deck).to_json,
        "battle_arena_events",
        "deck.update"
      )
    end
  end
end
