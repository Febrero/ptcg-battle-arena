module V1
  class SurvivalPlayerSerializer < ActiveModel::Serializer
    attributes :wallet_addr, :current_active_entry, :player_entries, :survival_id

    def player_entries
      object.entries.map { |e| e.attributes.except("_id") }
    end

    def current_active_entry
      return {} if object.active_entry.nil?

      object.active_entry.attributes.except("_id")
    end
  end
end
