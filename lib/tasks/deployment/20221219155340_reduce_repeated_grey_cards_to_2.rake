namespace :after_party do
  desc "Deployment task: reduce_repeated_grey_cards_to_2"
  task reduce_repeated_grey_cards_to_2: :environment do
    puts "Running deploy task 'reduce_repeated_grey_cards_to_2'"

    # Put your task implementation HERE.

    # Trigger callbacks to validate decks
    Deck.all.each do |d|
      d.save
    end

    # Destroy all sample decks
    SampleDeck.destroy_all

    # Generate new sample decks
    GenerateSampleDecks.call

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
