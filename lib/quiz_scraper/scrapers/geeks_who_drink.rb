module QuizScraper
  module GeeksWhoDrink
    Collection = ->(response) {
      venues = response["hits"]["hits"]
      venues.each_with_object([]) do |venue, result|
        raw_data = venue["_source"]
        reference = raw_data.delete("podioId")

        result << {
          name: raw_data['venueName'],
          reference: reference,
          raw_data: raw_data
        }
      end
    }

    class << self
      attr_accessor :base_url, :paginated

      GeeksWhoDrink.base_url = 'https://www.geekswhodrink.com'
      GeeksWhoDrink.paginated = false

      def find_all
        credentials = Credentials.(send_request('/schedule'))

        params = {
          host: credentials[:host],
          basic_auth: {
            user: credentials[:user],
            password: credentials[:password]
          }
        }

        collection = Collection.(
          send_request('/website/venue/_search?from=0&size=2000', params)
        )

        collection.map { |item| QuizScraper::Quiz.new(item, source: self) }
      end

      def find
      end
    end
  end

  private_constant(:GeeksWhoDrink)
end