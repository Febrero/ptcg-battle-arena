class ExportPlayoffsActivityMailer < ApplicationMailer
  def send_mail(email, csvs)
    csvs.each do |item|
      attachments[item[:name]] = {mime_type: "text/csv", content: item[:file]}
    end

    mail subject: "RealFevr - Playoffs Activity Export", to: email, body: ""
  end
end
