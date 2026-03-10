ActionMailer::Base.smtp_settings = {
  user_name: Rails.application.config.mandrill_username,
  password: Rails.application.config.mandrill_password,
  address: "smtp.mandrillapp.com",
  domain: "realfevr.com",
  enable_starttls_auto: true,
  authentication: "login",
  port: 587
}
ActionMailer::Base.delivery_method = :smtp

MandrillMailer.configure do |config|
  config.api_key = Rails.application.config.mandrill_password
  config.deliver_later_queue_name = :low
end
