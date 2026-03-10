namespace :after_party do
  desc "Deployment task: remove_duplicates_game_players"
  task demo_job: :environment do
    puts "Running deploy task 'remove_duplicates_game_players'"

    # Put your task implementation HERE.

    # the code should be send as a string, test it first before surround it with single quote
    AfterPartyJob
      .perform_async(AfterParty::Demo.to_s)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
