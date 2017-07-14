require "spec_helper"

RSpec.describe QuizScraper do
  it "has a version number" do
    expect(QuizScraper::VERSION).not_to be nil
  end

  context "on initialize" do
    let(:scraper_adapter) { QuizScraper::Scraper }

    it "raises ArgumentError when initialize without argument" do
      expect { scraper_adapter.new }.to raise_error(ArgumentError)
    end

    it "raises UndefinedScraperError when initialize with incorrect argument" do
      error = QuizScraper::ScraperLoader::UndefinedScraperError
      expect { scraper_adapter.new(:missing) }.to raise_error(error)
    end

    it "sets up scraper accessor for existing scraper" do
      adapter = scraper_adapter.new(:pub_quizzer)
      expect(adapter.scraper).to eq(QuizScraper::PubQuizzer)
    end

    context "extends specific scraper" do
      let(:extended_scraper) { scraper_adapter.new(:pub_quizzer).scraper }
      let(:singleton_klass) { extended_scraper.singleton_class }

      it "defines +process+ private singleton method" do
        expect(singleton_klass.private_method_defined?(:process)).to be_truthy
      end

      it "defines +send_request+ private singleton method" do
        expect(singleton_klass.private_method_defined?(:send_request)).to be_truthy
      end

      it "extends scraper with ActiveSupport::Inflector methods" do
        expect(extended_scraper.respond_to?(:parameterize)).to be_truthy
      end
    end
  end
end
