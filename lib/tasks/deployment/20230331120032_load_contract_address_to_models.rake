namespace :after_party do
  desc "Deployment task: load_contract_address_to_models"
  task load_contract_address_to_models: :environment do
    puts "Running deploy task 'load_contract_address_to_models'"

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    Ticket.all.each do |ticket|
      Denormalization::DenormalizeTicketInfoToTicketBalances.call(ticket)
      Denormalization::DenormalizeTicketInfoToTicketBundles.call(ticket)
      Denormalization::DenormalizeTicketInfoToTicketOffers.call(ticket)
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
