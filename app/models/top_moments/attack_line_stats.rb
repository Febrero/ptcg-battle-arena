module TopMoments
  class AttackLineStats < NftStats
    field :lane, type: Integer, default: TopMoments::NftStats::LANE_ATTACK_LINE
  end
end
