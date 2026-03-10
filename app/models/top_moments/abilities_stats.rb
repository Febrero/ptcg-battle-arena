module TopMoments
  class AbilitiesStats < NftStats
    field :lane, type: Integer, default: TopMoments::NftStats::LANE_ABILITIES

    field :super_sub, type: Integer
    field :captain, type: Integer
    field :inspire, type: Integer
    field :ball_stopper, type: Integer
    field :long_passer, type: Integer

    field :box_to_box, type: Integer
    field :dribbler, type: Integer
    field :manmark, type: Integer
  end
end
