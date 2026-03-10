module Configs
  class GetGameConfig < ApplicationService
    def call
      {
        contracts: {
          ticket_factory: {
            address: Rails.application.config.ticket_factory_contract_address
          },
          ticket_locker_and_distribution: {
            address: Rails.application.config.ticket_locker_and_distribution_contract_address
          }
        },
        tutorial: {
          steps: TutorialProgress::STEPS
        },
        standalone_build: standalone_build,
        splash_screens: ActiveModel::Serializer::CollectionSerializer.new(SplashScreen.active, serializer: V1::SplashScreenSerializer).as_json,
        asset_bundles: Rails.application.config.asset_bundles,
        translations: {
          url: "https://realfevr-production.s3.eu-central-1.amazonaws.com/translations/battle_arena/en/latest.json",
          version: "1.0.0"
        },
        links: {
          privacy_url: Rails.application.config.privacy_url,
          terms_conditions_url: Rails.application.config.terms_conditions_url,
          store_url: Rails.application.config.store_url,
          downloads_url: Rails.application.config.downloads_url,
          discord_url: Rails.application.config.discord_url,
          realfevr_url: Rails.application.config.realfevr_url,
          realfevr_marketplace_url: Rails.application.config.realfevr_marketplace_url,
          organya_url: Rails.application.config.organya_url,
          organya_marketplace_url: Rails.application.config.organya_marketplace_url,
          user_profile_url: Rails.application.config.user_profile_url,
          help_url: Rails.application.config.help_url,
          login_code_url: Rails.application.config.login_code_url,
          server_sockets_url: Rails.application.config.server_sockets_url

        },
        decks: Configs::GetConfig.call[:decks]
      }
    end

    private

    def standalone_build
      @standalone_build ||= begin
        V1::StandaloneBuildSerializer.new(StandaloneBuild.where(visibility: "public").order_by(version: "desc").first).to_h
      rescue
        nil
      end
    end
  end
end
