class FetchVideos < ApplicationService
  def call(search_params = {})
    cache_key = Rails.application.config.marketplace_videos_cache_key

    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      response = InternalApi.new.get("marketplace", request_uri: "/videos", query: search_params)

      case response.code
      when 200 then response.json
      when 408 then raise Net::HTTPRequestTimeout
      else; raise StandardError
      end
    end
  end
end
