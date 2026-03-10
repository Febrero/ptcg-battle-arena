FactoryBot.define do
  factory :goal_line_stats, parent: :nft_stats, class: "TopMoments::GoalLineStats" do
    lane { 0 }
  end
end
