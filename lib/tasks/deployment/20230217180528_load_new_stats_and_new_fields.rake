namespace :after_party do
  desc "Deployment task: load_new_stats_and_new_fields"
  task load_new_stats_and_new_fields: :environment do
    puts "Running deploy task 'load_new_stats_and_new_fields'"

    # Put your task implementation HERE.
    # LoadPlayersFromCsv.call("imports/videos_properties.csv", Video, true)
    # Deck.all.each do |d|
    #   d.save
    # end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
