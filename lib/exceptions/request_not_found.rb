class RequestNotFound < StandardError
  def to_s
    "The request not found"
  end
end
