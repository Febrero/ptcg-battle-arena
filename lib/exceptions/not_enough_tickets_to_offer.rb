class NotEnoughTicketsToOffer < StandardError
  def to_s
    "Not enough tickets available to offer"
  end
end
