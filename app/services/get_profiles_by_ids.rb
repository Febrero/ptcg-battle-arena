class GetProfilesByIds < ApplicationService
  def call(profile_ids_array = [])
    InternalApi.new.get("marketplace", request_uri: "/profiles/lite/?profile_ids_csv=#{profile_ids_array.join(",")}").json(true)
  end
end
