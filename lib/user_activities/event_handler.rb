module UserActivities
  class EventHandler
    attr_accessor :event

    def initialize(event)
      @event = event
    end

    def handle
      UserActivity.where("rewards.source_key": source_key).exists? ? handle_update_event : handle_create_event
    end

    def handle_create_event
      UserActivities::Reward.create(
        reward_type: reward_type,
        reward_subtype: reward_subtype,
        source: source,
        source_key: source_key,
        value: value,
        status: status,
        delivered_at: delivered_at,
        offer_detail: offer_detail,
        user_activity: user_activity
      )
    end

    def handle_update_event
      reward.update(status: status)
    end

    def status
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def reward_type
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def reward_subtype
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def offer_detail
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def source
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def source_key
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def value
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def delivered_at
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def user_activity
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
