class ChangePlayoffStateViaAdmin < ApplicationService
  def call(playoff_uid, state_event)
    playoff = Playoff.where(uid: playoff_uid).first
    if ["continue", "manual_finish", "pause"].include?(state_event) || (state_event == "finish" && playoff.state == "admin_pending")
      playoff.send("#{state_event}!")
    else
      raise UnrecognizedRewardStateEvent.new(state_event)
    end

    playoff.reload
  end
end
