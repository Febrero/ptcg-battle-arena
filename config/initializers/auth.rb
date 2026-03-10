require "#{Rails.root}/lib/auth"

Auth.configure do |config|
  config.auth_api_key = Rails.application.config.external_api_key
  config.authentication_service = Rails.application.config.authentication_service
end
