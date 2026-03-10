module TopMoments
  class DefenseLineStats < NftStats
    field :lane, type: Integer, default: TopMoments::NftStats::LANE_DEFENSE_LINE
  end
end
