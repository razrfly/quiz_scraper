module QuizScraper
  class Scraper
    attr_reader :scraper

    def initialize(scraper)
      raise ArgumentError unless scraper.is_a?(Class)
      @scraper = scraper and extend_scraper
    end

    def find_all(params = {})
      page = extract_page_param(params) if scraper.paginated
      page && scraper.send(:find_all, page) || scraper.send(:find_all)
    end

    def find(reference)
      scraper.send(:find, reference)
    end

    private

    def extract_page_param(params)
      return :default if params.empty?
      param = params.fetch(:page, nil)
      param &&= begin
        case temp = param
        when :all, 'all' then temp.to_sym
        when String then temp =~ /^\d+$/ and $&.to_i
        when Integer then temp
        end
      end
      param || :default
    end

    def extend_scraper
      scraper.tap do |scraper|
        require 'active_support/inflector'
        scraper.extend(QuizScraper::RequestHandler)
        scraper.extend(QuizScraper::RequestProcessor)
        scraper.extend(ActiveSupport::Inflector)
      end
    end
  end
end
