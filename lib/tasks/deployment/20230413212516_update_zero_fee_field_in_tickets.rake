namespace :after_party do
  desc 'Deployment task: update_fild_in_tickets'
  task update_zero_fee_field_in_tickets: :environment do
    puts "Running deploy task 'update_zero_fee_field_in_tickets'"

    # Put your task implementation HERE.
    Ticket.update_all(zero_fees: false, promo: false)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end