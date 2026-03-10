# Paginated Collection parser
#
# Parses the result of a decoded array of elements in order to fetch metadata
# pagination information aswell as the elements in the array.
#
class PaginatedCollection < ActiveResource::Collection
  attr_accessor :elements, :pagination_data, :response_hash

  def initialize parsed = {}
    @response_hash = parsed
    @elements = parsed["data"].map { |elem| elem["attributes"] }
    @pagination_data = parsed["meta"]
  end
end

module CustomJsonApiFormat
  include ActiveResource::Formats::JsonFormat

  extend self

  def decode(json)
    json_decoded = ActiveSupport::JSON.decode(json)

    data = json_decoded["data"]
    if data.is_a?(Hash)
      data["attributes"]
    else
      json_decoded
    end
  end
end
