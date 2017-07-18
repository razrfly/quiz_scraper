module QuizScraper
  class Quiz
    attr_reader :name, :reference, :raw_data

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end