FactoryBot.define do
  factory :defense_line_stats, parent: :nft_stats, class: "TopMoments::DefenseLineStats" do
    lane { 1 }
  end
end
