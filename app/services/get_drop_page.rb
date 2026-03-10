class GetDropPage < ApplicationService
  def call
    Rails.cache.fetch("GetDropPage", expires_in: 1.minute) do
      response = HTTParty.get(
        "#{Rails.application.config.realfevr_services[:admin][:service]}/api/v1/marketplace/drop_page",
        headers: {
          "X-RealFevr-Token" => Rails.application.config.realfevr_services[:admin][:external_api_key],
          "X-RealFevr-I-Token" => Rails.application.config.realfevr_services[:admin][:internal_api_key]
        }
      )
      case response.code
      when 200 then JSON.parse(response.body)
      when 408 then raise Net::HTTPRequestTimeout
      when 404 then raise DropPageNotFound
      else; raise StandardError
      end
    end
  end
end
