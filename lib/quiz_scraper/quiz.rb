module QuizScraper
  class Quiz
    attr_reader :source, :name, :reference, :raw_data, :scrape_status

    def initialize(params = {}, source:, origin:)
      @source = source
      @scrape_status = resolve_status(origin)

      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    private

    def resolve_status(origin)
      source.scrape_status[origin]
    end
  end
end