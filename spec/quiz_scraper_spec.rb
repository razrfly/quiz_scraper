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
  end
end
