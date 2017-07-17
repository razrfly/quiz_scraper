module QuizScraper
  class Scraper
    attr_reader :scraper

    def initialize(scraper)
      @scraper = ScraperLoader.call(scraper)
    end

    def find_all(params = {})
      page = extract_page_param(params) if scraper.paginated
      page && scraper.find_all(page) || scraper.find_all
    end

    def find(reference)
      scraper.find(reference)
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
  end
end
