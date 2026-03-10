# spec/serializers/article_serializer_spec.rb
require "rails_helper"

RSpec.describe V1::ArticleSerializer, type: :serializer do
  let(:article) { create(:article) }
  let(:serializer) { described_class.new(article) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  subject { JSON.parse(serialization.to_json) }

  it "includes the expected article attributes" do
    expect(subject.keys).to contain_exactly(
      "uid",
      "title",
      "subtitle",
      "cover_image_url",
      "description",
      "url",
      "active",
      "start_date",
      "end_date",
      "position_order",
      "created_at",
      "updated_at"
    )
  end
end
