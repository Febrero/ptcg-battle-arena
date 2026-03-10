class LeaderboardSourceNotAvailable < StandardError
  def to_s
    "The source is not available"
  end
end
