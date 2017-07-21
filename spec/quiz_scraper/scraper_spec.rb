require "spec_helper"

RSpec.describe QuizScraper::Scraper do
  it "has a version number" do
    expect(QuizScraper::VERSION).not_to be nil
  end

  let(:namespace) { QuizScraper }
  let(:adapter) { QuizScraper::Scraper }

  context "on initialize" do
    it "has ScraperLoader module on the same namespace" do
      expect(namespace.constants).to include(:ScraperLoader, :Scraper)
    end

    it "raises ArgumentError when initialize without argument" do
      expect { adapter.new }.to raise_error(ArgumentError)
    end

    it "sets up scraper reader for existing scraper" do
      scraper = adapter.new(:pub_quizzer).scraper
      expect(scraper).to eq(QuizScraper.const_get(:PubQuizzer))
    end

    it "raises UndefinedScraperError when initialize with incorrect scraper" do
      error = QuizScraper::ScraperLoader::UndefinedScraperError
      expect { adapter.new(:missing) }.to raise_error(error)
    end

    it "refutes to reference specific scraper module directly" do
      expect { QuizScraper::PubQuizzer }.to raise_error(NameError)
    end
  end

  context "when initialized" do
    it "has +find_all+ method defined for external usage" do
      expect(adapter.public_instance_methods).to include(:find_all)
    end

    it "has +find+ method defined for external usage" do
      expect(adapter.public_instance_methods).to include(:find)
    end
  end
end
