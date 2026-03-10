module Callbacks
  module TicketBundleCallbacks
    def before_create(ticket_bundle)
      denormalize_ticket_info_to_ticket_bundles(ticket_bundle)
    end

    private

    def denormalize_ticket_info_to_ticket_bundles(ticket_bundle)
      Denormalization::DenormalizeTicketInfoToTicketBundles.call(ticket_bundle.ticket, ticket_bundle)
    end
  end
end
