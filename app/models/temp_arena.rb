class TempArena
  include Mongoid::Document

  store_in collection: "arenas"

  field :uid, type: Integer
  field :name, type: String
  field :total_prize_pool, type: Float
  field :prize_pool_winner_share, type: Float
  field :prize_pool_realfevr_share, type: Float
  field :compatible_ticket_ids, type: Array
  field :erc20, type: String
  field :erc20_name, type: String
  field :active, type: Boolean
  field :background_image_url, type: String
end

# GameMode.order(uid: :asc).all.map(&:uid)

# TempArena.all.each do |t_arena|
# 	arena = Arena.create({
# 		name: t_arena.name,
# 		total_prize_pool: t_arena.total_prize_pool,
# 		prize_pool_winner_share: t_arena.prize_pool_winner_share,
# 		prize_pool_realfevr_share: t_arena.prize_pool_realfevr_share,
# 		compatible_ticket_ids: t_arena.compatible_ticket_ids,
# 		erc20: t_arena.erc20,
# 		erc20_name: t_arena.erc20_name,
# 		active: t_arena.active,
# 		background_image_url: t_arena.background_image_url,
# 	})

# 	arena.update_attribute(:uid, t_arena.uid)
# end
