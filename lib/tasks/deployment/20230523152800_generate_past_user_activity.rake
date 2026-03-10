namespace :after_party do
  desc 'Deployment task: generate_past_user_activity'
  task generate_past_user_activity: :environment do
    puts "Running deploy task 'generate_past_user_activity'"

    # Put your task implementation HERE.
    AfterPartyJob
      .perform_async(AfterParty::GeneratePastUserActivity.to_s)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end