module QuizScraper
  module CountryMapper
    MAPPINGS = {
      [
        "UK", "England", "United Kingdom", "United Kingdon", "Wales",
        "United Kingdom ", "Ireland", "Scotland", "Northern Ireland"
      ] => 'United Kingdom'
    }

    def MAPPINGS.maps?(value)
      enum, result = keys.each, nil
      loop do
        e = enum.next
        e.respond_to?(:include?) && e.include?(value) && (result = self[e])
      end
      result
    end

    class << self
      def map(country_name)
        MAPPINGS.maps?(country_name) || country_name
      end
    end
  end
end
