class CreateTicketOfferJob < ApplicationJob
  sidekiq_options retry: 25, queue: :default, backtrace: true
  def perform(params)
    CreateTicketOffer.call(params)
  end
end
