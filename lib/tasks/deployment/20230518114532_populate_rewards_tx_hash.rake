namespace :after_party do
  desc 'Deployment task: populate_rewards_tx_hash'
  task populate_rewards_tx_hash: :environment do
    puts "Running deploy task 'populate_rewards_tx_hash'"

    # Put your task implementation HERE.
    AfterPartyJob.perform_async(AfterParty::PopulateRewardsTxHash.to_s)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end