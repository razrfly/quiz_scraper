module QuizScraper
  class Quiz
    attr_reader :name, :reference, :raw_data, :scrape_status

    def initialize(params = {})
      @scrape_status = params.delete(:scrape_status)

      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end