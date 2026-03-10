module Callbacks
  module StandaloneBuildCallbacks
    def before_save(build)
      replace_s3_by_cloud_front(build)
    end

    private

    def replace_s3_by_cloud_front(build)
      # Staging Bucket
      build.dmg_download_url = build.dmg_download_url.gsub("https://realfevr-staging.088dc84c27e7f24f210dee5866822e7c.r2.cloudflarestorage.com/", "https://st-r2.realfevr.com/")
      build.exe_download_url = build.exe_download_url.gsub("https://realfevr-staging.088dc84c27e7f24f210dee5866822e7c.r2.cloudflarestorage.com/", "https://st-r2.realfevr.com/")

      # Production Bucket
      build.dmg_download_url = build.dmg_download_url.gsub("https://realfevr-production.088dc84c27e7f24f210dee5866822e7c.r2.cloudflarestorage.com/", "https://r2.realfevr.com/")
      build.exe_download_url = build.exe_download_url.gsub("https://realfevr-production.088dc84c27e7f24f210dee5866822e7c.r2.cloudflarestorage.com/", "https://r2.realfevr.com/")
    end
  end
end
