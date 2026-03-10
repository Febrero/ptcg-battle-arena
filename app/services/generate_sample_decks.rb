class GenerateSampleDecks < ApplicationService
  RARITY_TYPES = %w[Unique Legendary Epic Special Common Grey]
  POSITIONS_TYPES = %w[Goalkeeper Defender Forward Midfielder]

  def call(drop_slugs)
    @drop_slugs = drop_slugs
    SampleDeck.delete_all
    # load sample decks properties from yaml and created an array of hashes with indiferent access
    sample_decks_properties = YAML.load_file("config/sample_decks_properties.yaml")
    sample_decks_properties = sample_decks_properties.map do |hash|
      ActiveSupport::HashWithIndifferentAccess.new(hash)
    end
    # creates 10 decks for each sample deck
    # properties type (eg. 10 decks of type A1)
    sample_decks_properties.each do |deck_properties|
      count = 0

      while count < 10
        # gets a randomly generated deck (deck may be nil if it fails to generate)
        sample_deck = generate_sample_deck(deck_properties)
        # if the deck is not nil, save it to the database
        next unless sample_deck
        count += 1

        SampleDeck.create!(
          video_ids: sample_deck[:video_ids],
          grey_card_ids: sample_deck[:grey_card_ids],
          type: sample_deck[:type],
          serial_number: count
        )
      end

      puts deck_properties
    end
  end

  private

  # generates a sample deck based on sample deck properties
  def generate_sample_deck(properties)
    deck_properties = properties.deep_dup
    get_grey_cards_array
    get_videos_array
    rarities_per_position = get_rarities_per_position
    result_deck = {video_ids: [], grey_card_ids: [], type: deck_properties[:type]}

    e1 = false
    e2 = false

    50.times do
      rarities = get_remaining_rarities(deck_properties)
      positions = get_remaining_positions(deck_properties)
      position = positions.first

      card1 = e1 ? nil : @videos.where(
        uid: 9998,
        position: position
      ).in(
        rarity: rarities
      ).in(
        rarity: rarities_per_position[position]
      ).sample

      card2 = e2 ? nil : @videos.where(
        uid: 9999,
        position: position
      ).in(
        rarity: rarities
      ).in(
        rarity: rarities_per_position[position]
      ).sample

      # if there are missing cards that are not grey cards in the deck
      if rarities.count { |rarity| rarity != "Grey" } > 0
        if !e1 && card1 && deck_properties[:type] >= "E1"
          deck_properties[:rarities][card1[:rarity]] -= 1
          deck_properties[:positions][card1[:position]] -= 1
          result_deck[:video_ids].push(card1[:uid])

          e1 = true
        elsif !e2 && card2 && deck_properties[:type] >= "E1"
          deck_properties[:rarities][card2[:rarity]] -= 1
          deck_properties[:positions][card2[:position]] -= 1
          result_deck[:video_ids].push(card2[:uid])

          e2 = true
        else
          card = @videos.where(
            position: position
          ).in(
            rarity: rarities
          ).in(
            rarity: rarities_per_position[position]
          ).not_in(uid: [9998, 9999]).sample

          deck_properties[:rarities][card[:rarity]] -= 1
          deck_properties[:positions][card[:position]] -= 1
          result_deck[:video_ids].push(card[:uid])
          # randomly select a nft card following the logic requirements

          # if there are only grey cards missing in the deck
        end
      else
        # randomly select a grey card following the logic requirements
        card = @grey_cards.where(
          position: position
        ).not_in(
          uid: get_elements_repeated_n_times(
            result_deck[:grey_card_ids],
            1 # max repeated grey cards
          )
        ).sample

        deck_properties[:rarities][card[:rarity]] -= 1
        deck_properties[:positions][card[:position]] -= 1
        result_deck[:grey_card_ids].push(card[:uid])
      end
    rescue => e
      puts e.message
      puts e.backtrace.first(30).join("\n")
      return nil
    end
    result_deck
  end

  def get_elements_repeated_n_times(arr, n)
    result = []
    h = Hash.new(0)
    arr.each { |e| h[e] += 1 }
    h.each do |key, value|
      result << key if value == n
    end
    result
  end

  def get_remaining_positions(properties)
    remaining_positions = []
    POSITIONS_TYPES.each do |p|
      remaining_positions.push(p) if properties[:positions][p] > 0
    end
    remaining_positions
  end

  def get_remaining_rarities(properties)
    remaining_rarities = []
    RARITY_TYPES.each do |p|
      remaining_rarities.push(p) if properties[:rarities][p] > 0
    end
    remaining_rarities.shuffle
  end

  def get_grey_cards_array
    @grey_cards ||= GreyCard.in(drop_slug: @drop_slugs)
  end

  def get_videos_array
    @videos ||= FetchVideos.call({filter: {drop_slug: @drop_slugs.join(",")}})
  end

  def get_rarities_per_position
    get_grey_cards_array
    get_videos_array
    rarities_per_position = {}
    POSITIONS_TYPES.each do |position|
      rarities_per_position[position] = @videos.where(position: position).distinct(:rarity)
    end
    rarities_per_position
  end
end
