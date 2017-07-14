module QuizScraper
  module ScraperLoader
    require 'active_support/inflector'
    extend ActiveSupport::Inflector
    UndefinedScraperError = Class.new(StandardError)

    class << self
      def call(scraper)
        scraper = classify(scraper)

        raise(UndefinedScraperError) unless QuizScraper.const_defined?(scraper)

        QuizScraper.const_get(scraper).tap do |scraper|
          scraper.extend(QuizScraper::RequestHandler)
          scraper.extend(QuizScraper::RequestProcessor)
          scraper.extend(ActiveSupport::Inflector)
        end
      end
    end
  end
end
