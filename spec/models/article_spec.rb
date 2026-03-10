# spec/models/article_spec.rb
require "rails_helper"

RSpec.describe Article, type: :model do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:subtitle) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:cover_image_url) }
    it { should validate_presence_of(:active) }

    context "when active is true" do
      subject { build(:article, active: true) }

      context "when there are already 5 active articles" do
        before { create_list(:article, 5, active: true) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:active]).to include("There are already 5 active articles")
        end
      end
    end

    context "when start_date is present" do
      subject { build(:article, start_date: start_date, end_date: end_date) }

      context "when start_date is after end_date" do
        let(:start_date) { 1.day.from_now }
        let(:end_date) { 1.day.ago }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:start_date]).to include("Must be before the end date")
        end
      end
    end

    context "when end_date is present" do
      subject { build(:article, start_date: start_date, end_date: end_date) }

      context "when end_date is before start_date" do
        let(:start_date) { 1.day.from_now }
        let(:end_date) { 1.day.ago }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:end_date]).to include("Must be after the start date")
        end
      end
    end

    context "when there are already #{Article::MAX_ACTIVE_ARTICLES} active articles and one inactive article" do
      let!(:active_articles) { create_list(:article, Article::MAX_ACTIVE_ARTICLES, active: true) }
      let!(:inactive_article) { create(:article, active: false) }

      it "does not allow the inactive article to be updated to active" do
        inactive_article.active = true

        expect(inactive_article).not_to be_valid
        expect(inactive_article.errors[:active]).to include("There are already 5 active articles")
      end
    end
  end
end
