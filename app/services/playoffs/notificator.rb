module Playoffs
  class Notificator
    include FieldEnumerable
    include Callable

    attr_reader :playoff, :message_type, :message_details

    field_enum type: {
      state: "state",
      round: "round",
      process_game: "process_game",
      join_team: "join_team"
    }, _prefix: true

    def initialize(playoff_uid, message_type, message_details = {})
      @playoff = Playoff.find_by(uid: playoff_uid.to_i)
      @message_type = message_type
      @message_details = message_details
    end

    def call
      Rails.logger.info "Going send message to notificator #{message_type}"
      message = nil
      if message_type.is_a?(String) || message_type.is_a?(Symbol)
        message = send(message_type.to_s)
      end

      Rabbitmq::PlayoffsPublisher.send(message_type.to_s, message.to_json) if message
    rescue NoMethodError
      Rails.logger.error "The message type not exist #{message_type}"
    end

    private

    def state
      timeframes = playoff.timeframes

      next_state_info = {}
      if playoff.state == "upcoming"
        next_state_info = {
          state: "opened",
          date: timeframes[:registration_start]
        }
      end

      if playoff.state == "opened"
        next_state_info = {
          state: "warmup",
          date: timeframes[:registration_end]
        }
      end

      if playoff.state == "warmup"
        next_state_info = {
          state: "ongoing",
          date: timeframes[:start_date]
        }
      end

      if playoff.state == "ongoing"
        next_state_info = {
          state: "finished",
          date: timeframes[:end_date]
        }
      end

      {
        uid: playoff.uid,
        playoff_name: playoff.name,
        state: playoff.state,
        next_state_info: next_state_info
      }
    end

    def round
      {
        uid: playoff.uid,
        state: playoff.state,
        playoff_name: playoff.name,
        round: playoff.current_round,
        max_wait_minutes_to_join: playoff.max_wait_minutes_to_join,
        games: playoff.round_games(playoff.current_round)
      }
    end

    def process_game
      {
        uid: playoff.uid,
        round: playoff.current_round
      }.merge(message_details)
    end

    def join_team
      {
        uid: playoff.uid
      }.merge(message_details)
    end
  end
end
