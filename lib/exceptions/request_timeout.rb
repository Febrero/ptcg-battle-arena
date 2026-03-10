class RequestTimeout < StandardError
  def to_s
    "The request was timeout"
  end
end
