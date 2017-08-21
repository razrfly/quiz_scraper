module QuizScraper
  module RequestProcessor
    require 'nokogiri'

    private
    
    def process(response)
      yield(Nokogiri::HTML(response))
    end
  end
end
