module Callbacks
  module GameModePartnerConfigCallbacks
    def before_create(game_mode_partner_config)
      game_mode_partner_config.uid = (GameModePartnerConfig.max(:uid) || 0) + 1
    end
  end
end
