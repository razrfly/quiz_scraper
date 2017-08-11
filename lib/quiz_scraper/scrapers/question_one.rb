module QuizScraper
  module QuestionOne
    class << self
      attr_accessor :base_url, :paginated, :scrape_status

      QuestionOne.base_url = 'http://questionone.com'
      QuestionOne.paginated = false
      QuestionOne.scrape_status = {
        :find_all => :full
      }

      def find_all
      end
    end
  end

  private_constant(:QuestionOne)
end
