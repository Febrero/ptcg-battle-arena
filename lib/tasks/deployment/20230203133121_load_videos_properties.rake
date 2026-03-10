namespace :after_party do
  desc 'Deployment task: load_videos_properties'
  task load_videos_properties: :environment do
    puts "Running deploy task 'load_videos_properties'"

    LoadPlayersFromCsv.call("imports/videos_properties.csv", Video, true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
