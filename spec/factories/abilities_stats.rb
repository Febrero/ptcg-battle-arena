FactoryBot.define do
  factory :abilities, parent: :nft_stats, class: "TopMoments::AbilitiesStats" do
    lane { 3 }
    sequence(:super_sub)
    sequence(:captain)
    sequence(:inspire)
    sequence(:ball_stopper)
    sequence(:long_passer)
    sequence(:box_to_box)
    sequence(:dribbler)
    sequence(:manmark)
  end
end
