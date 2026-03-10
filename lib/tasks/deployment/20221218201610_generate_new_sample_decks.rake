namespace :after_party do
  desc "Deployment task: generate_new_sample_decks"
  task generate_new_sample_decks: :environment do
    puts "Running deploy task 'generate_new_sample_decks'"

    # Put your task implementation HERE.
    SampleDeck.destroy_all
    GenerateSampleDecks.call

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
