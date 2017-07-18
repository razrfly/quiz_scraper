module QuizScraper
  class Quiz
    attr_reader :source, :name, :reference, :raw_data

    def initialize(params = {}, source:)
      @source = source

      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end