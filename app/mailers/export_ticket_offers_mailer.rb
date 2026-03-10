class ExportTicketOffersMailer < ApplicationMailer
  def send_csv(csv, email)
    @csv = csv
    @email = email
    attachments["export.csv"] = {mime_type: "text/csv", content: csv}
    mail subject:  "RealFevr - Ticket Offers Export @ #{Time.now.localtime.strftime("%d-%m-%Y %H:%M")}",
      to: email
  end
end
