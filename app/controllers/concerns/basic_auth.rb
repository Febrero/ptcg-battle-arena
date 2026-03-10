module BasicAuth
  private

  def auth_frontend
    unless frontend || external_api
      head :forbidden
    end
  end

  def auth_external_api
    unless external_api
      head :forbidden
    end
  end

  def auth_internal_api
    unless internal_api
      head :forbidden
    end
  end

  def auth_event_listener
    unless event_listener
      head :forbidden
    end
  end

  def auth_frontend_or_internal_api
    unless frontend || internal_api
      head :forbidden
    end
  end

  def frontend
    request.headers["X-RealFevr-Token"] == Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s)
  end

  def external_api
    request.headers["X-RealFevr-Token"] == Rails.application.config.external_api_key || internal_api
  end

  def event_listener
    request.headers["X-RealFevr-Auth"] == Rails.application.config.auth_event_listener
  end

  def internal_api
    request.headers["X-RealFevr-I-Token"] == Rails.application.config.internal_api_key
  end
end
