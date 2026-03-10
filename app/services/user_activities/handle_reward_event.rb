module UserActivities
  class HandleRewardEvent < ApplicationService
    attr_accessor :event, :source

    def call(event, source)
      @event = event
      @source = source

      clazz_name = "UserActivities::EventHandlers::#{source_class}::#{event_type_class}"

      # Rewards may be generated via dropbook creation (without event_type) or by sources not mapped(Referral)
      return if event_type_class.blank? || !Object.const_defined?(clazz_name)

      clazz_name.constantize.new(event).handle
    rescue Mongoid::Errors::NoParent => e
      Airbrake.notify(e)
    end

    private

    def source_class
      source.capitalize
    end

    def event_type_class
      event_types = {
        "prizes" => event["match_type"],
        "rewards" => event["event_type"]
      }
      event_types[source.downcase]
    end
  end
end
