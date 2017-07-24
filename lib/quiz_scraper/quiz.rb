module QuizScraper
  class Quiz
    attr_reader :name, :scrape_status, :reference, :location, :raw_data

    def initialize(params = {})
      @scrape_status = params.delete(:scrape_status)

      build_quiz_location(params.delete(:location)) if scrape_full?

      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def scrape_full?
      scrape_status == :full
    end

    def scrape_partial?
      scrape_status == :partial
    end

    private

    def build_quiz_location(params)
      @location = QuizLocation.new(params)
    end
  end
end