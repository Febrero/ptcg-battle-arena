class ExportTicketOffers < ApplicationService
  def call email
    fields = %w[ticket_id wallet_addr offered tx_hash]
    csv = ConvertModelToCsv.call TicketOffer, fields
    ExportTicketOffersMailer.send_csv(csv, email).deliver_now
  end
end
