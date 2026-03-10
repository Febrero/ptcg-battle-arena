class ExportTicketOffersJob < ApplicationJob
  sidekiq_options retry: 10, queue: :default, backtrace: true

  def perform(email)
    ExportTicketOffers.call(email)
  end
end
