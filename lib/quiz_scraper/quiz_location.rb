module QuizScraper
  class QuizLocation
    def initialize(params)
      coordinates = params.delete(:coordinates)

      @longitude = coordinates[:longitude]
      @latitude = coordinates[:latitude]

      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
