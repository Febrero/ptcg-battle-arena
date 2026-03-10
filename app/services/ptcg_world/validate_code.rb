# frozen_string_literal: true

module PtcgWorld
  class ValidateCode
    PTCG_API_URL = ENV.fetch("PTCG_WORLD_API_URL", "https://ptcg.world")
    SHARED_SECRET = ENV.fetch("PTCG_BATTLE_ARENA_SHARED_SECRET", "changeme")

    def self.call(code)
      uri = URI("#{PTCG_API_URL}/api/battle-arena/validate")
      uri.query = URI.encode_www_form(code: code)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{SHARED_SECRET}"
      request["Content-Type"] = "application/json"
      
      response = http.request(request)
      
      case response.code.to_i
      when 200
        JSON.parse(response.body)
      when 401
        raise "Unauthorized: invalid shared secret"
      when 404
        raise "Invalid or expired code"
      else
        raise "ptcg.world error: #{response.code}"
      end
    end
  end
end
