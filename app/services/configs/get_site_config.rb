module Configs
  class GetSiteConfig < ApplicationService
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
        standalone_build: standalone_build
      }
    end

    private

    def standalone_build
      builds = StandaloneBuild.where(visibility: "public").to_a
      builds_ordered = builds.sort_by { |build| Gem::Version.new(build.version) }

      @standalone_build ||= begin
        V1::StandaloneBuildSerializer.new(builds_ordered.last).to_h
      rescue
        nil
      end
    end
  end
end
