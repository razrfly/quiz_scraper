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
      attr_accessor :base_url, :paginated, :scrape_status

      GeeksWhoDrink.base_url = 'https://www.geekswhodrink.com'
      GeeksWhoDrink.paginated = false
      GeeksWhoDrink.scrape_status = {
        :find_all => :full
      }

      def find_all
        params = {
          host: "https://dori-us-east-1.searchly.com",
          headers: {
            "Host" => "dori-us-east-1.searchly.com",
            "User-Agent" => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0'",
            "Accept" => "application/json",
            "Accept-Language" => "en-US,en;q=0.5",
            "Authorization" => "Basic d2Vic2l0ZTpxaGJnbDVsczJ1Zm12cjI1aHFwNGhtdGVyaWZhbnplNw==",
            "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
            "Referer" => "https://www.geekswhodrink.com/schedule",
            "origin" => "https://www.geekswhodrink.com",
            "DNT" => "1",
            "Connection" => "keep-alive"
          },
          body: {
            :query => {
              :bool => {
                :must => [
                  { :match => { :brands => "gwd" } }
                ],
                :must_not => [
                  { :match => { :status => "Terminated" } },
                  { :match => { :status => "Content Only" } },
                  { :match => { :status => "On Hiatus" } },
                  { :match => { :status => "Failed" } }
                ],
                :should => [
                  { :match => { :status => "Active" } },
                  { :match => { :status => "In Progress" } },
                  { :match => { :status => "Ready to Boot" } }
                ]
              }
            },
            :sort => [
              { :"venueName.venueName_na" => {} }
            ]
          }.to_json
        }

        collection = Collection.(
          send_request('/website/venue/_search?from=0&size=2000', :post, params)
        )

        collection.map { |item| QuizScraper::Quiz.new(item, source: self) }
      end
    end
  end

  private_constant(:GeeksWhoDrink)
end