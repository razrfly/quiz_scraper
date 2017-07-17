module QuizScraper
  module GeeksWhoDrink
    Credentials = ->(response) {
      scripts = process(response) { |document| document.css('script') }
      script = scripts.children.first

      data = script.text =~ /\{.*\}/ and (data = $& || '{}')

      parsed_data = JSON.parse(data).dig("settings", "elasticsearch", "host")
      parsed_data =~ /^https:\/\/(.*):(.*)@(.*)\z/

      a = { user: $1, password: $2, host: "https://#{$3}" }
    }
    private_constant(:Credentials)

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