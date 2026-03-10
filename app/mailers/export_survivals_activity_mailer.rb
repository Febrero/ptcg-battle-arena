class ExportSurvivalsActivityMailer < ApplicationMailer
  def send_mail(email, csvs)
    csvs.each do |item|
      attachments[item[:name]] = {mime_type: "text/csv", content: item[:file]}
    end

    mail subject: "RealFevr - Survivals Activity Export", to: email, body: ""
  end
end
