# module UserActivities
#   class HandleRewardEvent < ApplicationService
#     attr_accessor :event, :source

#     def call(event, source)
#       @event = event
#       @source = source

#       "UserActivities::EventHandlers::#{source_class}::#{event_type_class}".constantize.new(event).handle
#     end

#     private

#     def source_class
#       source.capitalize
#     end

#     def event_type_class
#       {
#         "prizes" => event["match_type"],
#         "rewards" => event["event_type"]
#       }
#     end
#   end
# end

require "rails_helper"

RSpec.describe UserActivities::HandleRewardEvent do
  let(:prize_arena_event) { {"match_type" => "Arena"} }
  let(:prize_survival_event) { {"match_type" => "Survival"} }
  let(:reward_arena_event) { {"event_type" => "Arena"} }
  let(:reward_daily_game_event) { {"event_type" => "DailyGame"} }
  let(:reward_survival_event) { {"event_type" => "Survival"} }

  it "calls the correct class when prize arena event" do
    allow_any_instance_of(UserActivities::EventHandlers::Prizes::Arena).to receive(:handle).with(any_args)
    described_class.call(prize_arena_event, "Prizes")
  end

  it "calls the correct class when prize survival event" do
    allow_any_instance_of(UserActivities::EventHandlers::Prizes::Survival).to receive(:handle).with(any_args)
    described_class.call(prize_survival_event, "Prizes")
  end

  it "calls the correct class when prize survival event" do
    allow_any_instance_of(UserActivities::EventHandlers::Rewards::Arena).to receive(:handle).with(any_args)
    described_class.call(reward_arena_event, "Rewards")
  end

  it "calls the correct class when prize arena event" do
    allow_any_instance_of(UserActivities::EventHandlers::Rewards::DailyGame).to receive(:handle).with(any_args)
    described_class.call(reward_daily_game_event, "Rewards")
  end

  it "calls the correct class when prize arena event" do
    allow_any_instance_of(UserActivities::EventHandlers::Rewards::Survival).to receive(:handle).with(any_args)
    described_class.call(reward_survival_event, "Rewards")
  end
end
