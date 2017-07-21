require "spec_helper"

RSpec.describe QuizScraper::Scraper do
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

    context "page parameter extraction" do
      let(:scraper) { adapter.new(:pub_quizzer) }

      # We don't want to use full scale of +find_all+ method behavior,
      # so I mimic that behavior by defining singleton method.
      # This is just kind of container to test +extract_page_params+
      # method.

      let(:extend_scraper) {
        def scraper.find_all(params = {})
          extract_page_param(params)
        end
      }

      it "returns 'default' value for empty params" do
        extend_scraper
        expect(scraper.find_all).to eq(:default)
      end

      it "returns 'default' value for unpermitted params keys" do
        extend_scraper
        expect(scraper.find_all(not_allowed: 'not allowed')).to eq(:default)
      end

      it "returns 'default' value for correct key and nil value" do
        extend_scraper
        expect(scraper.find_all(page: nil)).to eq(:default)
      end

      it "returns 'default' value for correct key and unpermitted value" do
        extend_scraper
        expect(scraper.find_all(page: [])).to eq(:default)
      end

      it "returns 'default' value for correct key and unpermitted String value" do
        extend_scraper
        expect(scraper.find_all(page: 'nope')).to eq(:default)
      end

      it "returns value for correct key and permitted String value" do
        extend_scraper
        expect(scraper.find_all(page: '1')).to eq(1)
      end

      it "returns value for correct key and permitted Integer value" do
        extend_scraper
        expect(scraper.find_all(page: 1)).to eq(1)
      end

      it "returns 'all' value when invoked with custom :all page param" do
        extend_scraper
        expect(scraper.find_all(page: :all)).to eq(:all)
      end
    end
  end
end
