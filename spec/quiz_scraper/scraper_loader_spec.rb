require "spec_helper"

RSpec.describe QuizScraper::ScraperLoader do
  context "when new scraper has been initialized" do
    let(:namespace) { QuizScraper::ScraperLoader }
    let(:adapter) { QuizScraper::Scraper.new(:pub_quizzer) }
    let(:scraper) { adapter.scraper }

    it "has defined UndefinedScraperError class" do
      expect(namespace.constants).to include(:UndefinedScraperError)
    end

    it "extends scraper with ActiveSupport::Inflector methods" do
      expect(
        scraper.respond_to?(:parameterize)
      ).to be_truthy
    end

    it "defines +process+ private singleton method" do
      expect(
        scraper.singleton_class.private_method_defined?(:process)
      ).to be_truthy
    end

    it "defines +send_request+ private singleton method" do
      expect(
        scraper.singleton_class.private_method_defined?(:send_request)
      ).to be_truthy
    end
  end
end
