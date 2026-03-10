namespace :after_party do
  desc 'Deployment task: Set'
  task populate_tickets_position: :environment do
    puts "Running deploy task 'populate_tickets_position'"

    # Put your task implementation HERE.

    Ticket.all.each_with_index do |t, i|
      t.update(position: i, sale_expiration_date: 45.days.from_now)
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
