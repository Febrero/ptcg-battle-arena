module TopMoments
  class GoalLineStats < NftStats
    field :lane, type: Integer, default: TopMoments::NftStats::LANE_GOAL_LINE
  end
end
