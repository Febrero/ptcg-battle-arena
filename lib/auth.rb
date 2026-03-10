# Auth module — replaces fantasy-revolution-users-auth gem
# Validates JWTs issued by this app's own PtcgAuthController
require "jwt"

module Auth
  # Exceptions
  class BadRequest < StandardError; end
  class UserUnauthorized < StandardError; end
  class Forbidden < StandardError; end

  # Configuration (kept for compatibility with auth.rb initializer)
  class << self
    attr_accessor :auth_api_key, :authentication_service

    def configure
      yield self
    end
  end

  # User auth — validates Bearer JWT issued by /v1/auth/ptcg_code
  class User
    attr_reader :ptcg_user_id, :email, :username

    def initialize(payload)
      @ptcg_user_id = payload["ptcg_user_id"] || payload["sub"]
      @email        = payload["email"]
      @username     = payload["username"]
    end

    def self.validate_auth(authorization_header)
      raise Auth::UserUnauthorized if authorization_header.blank?

      token = authorization_header.to_s.sub(/\ABearer\s+/i, "")
      raise Auth::UserUnauthorized if token.blank?

      secret = ENV.fetch("JWT_SECRET") { raise Auth::UserUnauthorized }

      begin
        payload, _header = JWT.decode(token, secret, true, algorithm: "HS256")
      rescue JWT::ExpiredSignature
        raise Auth::UserUnauthorized
      rescue JWT::DecodeError
        raise Auth::UserUnauthorized
      end

      new(payload)
    end
  end
end
