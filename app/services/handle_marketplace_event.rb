class HandleMarketplaceEvent < ApplicationService
  VIDEOS_CACHE_RESET_ATTRIBUTES = [
    "position", "defense", "attack", "stamina", "ball_stopper", "super_sub", "man_mark", "enforcer",
    "inspire", "captain", "long_passer", "box_to_box", "dribbler", "power", "enabler", "energizer", "power"
  ]

  def call(routing_key, event)
    handle_video_change(event) if is_video_change_event?(routing_key)
    handle_videos_imported(event) if is_videos_import_event?(routing_key)
  end

  private

  def handle_video_change(event)
    if (event["changes"].keys & VIDEOS_CACHE_RESET_ATTRIBUTES).size > 0
      cache_key = Rails.application.config.marketplace_videos_cache_key

      Rails.cache.delete(cache_key)
    end
  end

  def handle_videos_imported(event)
    UpdateDecksJob.perform_async
  end

  def is_videos_import_event?(routing_key)
    routing_key == "video.videos_imported"
  end

  def is_video_change_event?(routing_key)
    ["video.update", "video.create", "video.delete"].include?(routing_key)
  end
end
