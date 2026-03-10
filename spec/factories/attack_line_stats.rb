FactoryBot.define do
  factory :attack_line_stats, parent: :nft_stats, class: "TopMoments::AttackLineStats" do
    lane { 2 }
  end
end
