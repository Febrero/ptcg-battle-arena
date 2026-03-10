class FetchTokens < ApplicationService
  def call(search_params)
    response = InternalApi.new.get("marketplace", request_uri: "/tokens", query: search_params)

    case response.code
    when 200 then response.json
    when 408 then raise Net::HTTPRequestTimeout
    else; raise StandardError
    end
  end
end
