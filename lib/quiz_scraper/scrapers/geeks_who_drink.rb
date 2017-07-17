module QuizScraper
  module GeeksWhoDrink
    class << self
      attr_accessor :base_url, :paginated

      GeeksWhoDrink.base_url = 'https://www.geekswhodrink.com'
      GeeksWhoDrink.paginated = false

      def find_all
      end

      def find
      end
    end
  end

  private_constant(:GeeksWhoDrink)
end