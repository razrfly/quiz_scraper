module QuizScraper
  module RequestProcessor
    require 'nokogiri'
    
    def process(response)
      yield(Nokogiri::HTML(response))
    end
  end
end
