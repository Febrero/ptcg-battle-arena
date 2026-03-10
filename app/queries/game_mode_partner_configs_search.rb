class GameModePartnerConfigsSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "name", type: :value}
  ]

  def initialize(params)
    super(params, GameModePartnerConfig)
  end
end
