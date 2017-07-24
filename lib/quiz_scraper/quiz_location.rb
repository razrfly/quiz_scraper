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

    private

    def method_missing(name, *args)
      instance_variable_defined?("@#{name}") ?
        instance_variable_get("@#{name}") : super
    end

    def respond_to_missing?(name, include_private = false)
      instance_variable_defined?("@#{name}") || super
    end
  end
end
