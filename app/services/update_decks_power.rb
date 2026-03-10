class UpdateDecksPower < ApplicationService
  def call
    Deck.each do |deck|
      deck.save
    end
    SampleDeck.each do |sample_deck|
      sample_deck.save
    end
  end
end
