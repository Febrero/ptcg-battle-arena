require "rails_helper"

RSpec.describe Survivals::OpenSurvival do
  describe "update of survival state" do
    it "should open all incoming survivals that passed the start_date" do
      create_list(:survival, 2, :incoming, start_date: (Time.now - 10.days))
      create(:survival, :incoming, start_date: (Time.now + 10.days))

      expect {
        subject.call
      }.to change {
             Survival.active.count
           }.from(0).to(2)
    end

    it "should not open incoming survivals with future start_date" do
      create_list(:survival, 2, :incoming, start_date: (Time.now - 10.days))
      create(:survival, :incoming, start_date: (Time.now + 10.days))

      expect {
        subject.call
      }.to change {
             Survival.incoming.count
           }.from(3).to(1)
    end
  end
end
