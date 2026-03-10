class GetProfilesByWalletAddresses < ApplicationService
  def call(params = {})
    response = HTTParty.get(
      "#{Rails.application.config.realfevr_services[:user_profile][:service]}/profile?#{params.to_query}",
      headers: {
        "X-RealFevr-I-Token": Rails.application.config.realfevr_services[:user_profile][:internal_api_key]
      }
    )

    case response.code
    when 200 then JSON.parse(response.body)
    when 408 then raise Net::HTTPRequestTimeout
    else; raise StandardError
    end
  end
end
