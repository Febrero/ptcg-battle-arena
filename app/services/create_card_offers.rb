class CreateCardOffers < ApplicationService
  def call(params)
    # checks if card offer params are valid - raises InvalidCardOfferParams if they are not
    validate_card_offer_params(params)

    # persist card offers
    card_offers = create_card_offers(params)

    # deliver card offers
    offered_grey_card_uids = []
    card_offers.each do |card_offer|
      grey_card_ids = deliver_card_offer(card_offer)
      offered_grey_card_uids += grey_card_ids
    end

    # create the starter deck if create_starter_deck is true
    if create_starter_deck?(params)
      generate_starter_deck(params[:wallet_addr], offered_grey_card_uids)
    end
  end

  private

  def validate_card_offer_params(params)
    case params[:card_type]
    when "grey_card"
      raise InvalidCardOfferParams unless params[:offer_detail][:cards].is_a?(Array)

      params[:offer_detail][:cards].each do |card_detail|
        valid_fields = GreyCard.fields.keys
        valid_fields += ["id", "quantity"]

        raise InvalidCardOfferParams if card_detail[:quantity].nil? && card_detail[:uid].nil?

        # if filter keys are invalid
        card_detail.keys.each do |key|
          raise InvalidCardOfferParams unless valid_fields.include?(key.to_s)
        end

        # if quantity is invalid
        if card_detail[:uid].present? && card_detail[:quantity].present? && card_detail[:quantity] > 1
          raise InvalidCardOfferParams
        end

        # if grey card uid is invalid
        if card_detail[:uid].present? && GreyCard.where(uid: card_detail[:uid]).empty?
          raise InvalidCardOfferParams
        end
      end
    else
      raise InvalidCardOfferParams
    end
  end

  def create_card_offers(params)
    params[:offer_detail][:cards].map do |card_detail|
      card_offer = CardOffer.create(
        quantity: card_detail[:uid].present? ? 1 : card_detail[:quantity],
        wallet_addr: params[:wallet_addr],
        reward_key: params[:reward_key],
        source: params[:source],
        card_type: params[:card_type],
        offer_detail: card_detail.to_h,
        delivered: true,
        delivered_at: Time.now
      )

      card_offer
    end
  end

  def deliver_card_offer(card_offer)
    case card_offer.card_type
    when "grey_card" then deliver_grey_card(card_offer)
    end
  end

  def deliver_grey_card(card_offer)
    grey_card_uids = []

    card_detail = card_offer.offer_detail

    card_detail.delete(:quantity)

    quantity = 1 if card_detail[:uid].present?

    grey_cards = GreyCard.where(card_detail).sample(quantity)

    grey_cards.each do |grey_card|
      WalletGreyCard.create!(wallet_addr: card_offer.wallet_addr, grey_card: grey_card)

      grey_card_uids << grey_card.uid
    end

    grey_card_uids
  end

  def generate_starter_deck(wallet_addr, grey_card_ids)
    deck = Deck.where(name: "Starter deck", wallet_addr: wallet_addr).first_or_initialize
    deck.grey_card_ids = grey_card_ids
    deck.save!
  end

  def create_starter_deck?(params)
    ActiveModel::Type::Boolean.new.cast(params[:offer_detail][:create_starter_deck])
  end
end
