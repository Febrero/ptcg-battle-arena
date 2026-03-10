class ApplicationController < ActionController::API
  def ping
    status = { status: "ok", checks: {} }

    # Test MongoDB — non-fatal
    begin
      Deck.first
      status[:checks][:mongodb] = "ok"
    rescue => e
      status[:checks][:mongodb] = "unavailable: #{e.class}"
    end

    # Test Redis — non-fatal
    begin
      get_redis.get("SOMEKEY")
      status[:checks][:redis] = "ok"
    rescue => e
      status[:checks][:redis] = "unavailable: #{e.class}"
    end

    render json: status, status: :ok
  end

  protected

  def user_or_external_api_auth
    authenticate_user!
  rescue Auth::UserUnauthorized
    auth_external_api
  end

  def authenticate_user!
    raise Auth::UserUnauthorized if request.headers["Authorization"].blank?
    @user_data = Auth::User.validate_auth request.headers["Authorization"]
  end

  rescue_from Auth::BadRequest do |exception|
    render json: exception.message, status: :bad_request
  end

  rescue_from Auth::UserUnauthorized do |exception|
    render json: exception.message, status: :unauthorized
  end

  rescue_from Auth::Forbidden do |exception|
    render json: exception.message, status: :forbidden
  end
end
