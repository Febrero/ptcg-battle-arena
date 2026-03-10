FactoryBot.define do
  factory :sample_deck, class: "SampleDeck" do
    type { "#{rand(65..89).chr}#{rand(20)}" }
    serial_number { rand(1000) }
    video_ids { [] }
    grey_card_ids { [] }
  end
end
