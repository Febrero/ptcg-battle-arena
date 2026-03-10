class FetchVideo < ApplicationService
  def call(uid)
    response = InternalApi.new.get("marketplace", request_uri: "/videos/#{uid}")

    case response.code
    when 200 then response.json
    when 408 then raise Net::HTTPRequestTimeout
    else; raise StandardError
    end
  end
end
