require "rails_helper"

RSpec.describe ArticlesSearch, type: :model do
  let(:params) { {filter: {active: true}} }
  let(:article_search) { ArticlesSearch.new(params) }
  let!(:article1) { create(:article, active: true, position_order: 1) }
  let!(:article2) { create(:article, active: true, position_order: 2) }
  let!(:article3) { create(:article, active: true, position_order: 3) }
  let!(:article4) { create(:article, active: true, position_order: 4) }
  let(:inactive_article) { create(:article, active: false) }

  describe "#initialize" do
    it "initializes with given params" do
      expect(article_search.params).to eq(params)
    end
  end

  describe "#default_scope" do
    context "when all filter values are nil" do
      let(:params) { {filter: {}} }

      it "returns articles with active: true and date conditions" do
        result = article_search.send(:default_scope)
        expect(result).not_to include(inactive_article)
      end

      it "returns articles ordered by " do
        collection, _page, _per_page, _total = article_search.search
        expect(collection.first.position_order).to eq(1)
      end

      it "serializer" do
        articles, _page, _per_page, _total = ArticlesSearch.new({}).search
        serializer = ActiveModel::Serializer::CollectionSerializer.new(
          articles,
          {serializer: V1::ArticleSerializer}
        )

        expect(JSON.parse(serializer.to_json).first["title"]).to eq(article1.title)
      end
    end
  end
end
