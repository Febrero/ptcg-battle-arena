class UpdateDecks < ApplicationService
  def call
    Deck.all.each do |deck|
      deck.save
    end
  end
end
