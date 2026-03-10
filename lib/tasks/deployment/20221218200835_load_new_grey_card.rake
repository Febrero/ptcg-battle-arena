namespace :after_party do
  desc "Deployment task: load_new_grey_card"
  task load_new_grey_card: :environment do
    puts "Running deploy task 'load_new_grey_card'"

    # Put your task implementation HERE.
    LoadPlayersFromCsv.call("imports/grey_cards_properties.csv", GreyCard, true)

    Deck.all.each do |d|
      d.save
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
