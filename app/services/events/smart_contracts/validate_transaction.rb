module Events
  module SmartContracts
    class ValidateTransaction < ApplicationService
      def call(event)
        event_transaction = EventTransaction.where(tx_hash: event["tx_hash"], log_index: event["log_index"]).first
        if !event_transaction
          EventTransaction.create(
            tx_hash: event["tx_hash"],
            block_number: event["block_number"],
            log_index: event["log_index"],
            tx_index: event["tx_index"],
            name: event["event_name"]
          )
          true
        elsif !event_transaction["reverted"] && event["removed"]
          event_transaction.update(reverted: true)
          true
        else
          false
        end
      end
    end
  end
end
