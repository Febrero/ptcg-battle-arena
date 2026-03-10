class FetchToken < ApplicationService
  def call(name)
    return nil unless name

    response = InternalApi.new.get("marketplace", request_uri: "/tokens/#{name}")
    case response.code
    when 200 then response.json
    when 408 then raise Net::HTTPRequestTimeout
    else; raise StandardError
    end
  end
end
