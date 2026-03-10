class InvalidCardOfferParams < StandardError
  def to_s
    "The card offer params provided are not valid"
  end
end
