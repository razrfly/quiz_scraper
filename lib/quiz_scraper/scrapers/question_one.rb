module QuizScraper
  module QuestionOne
    EDITIONS = %w(uk us au).freeze

    Collection = ->(response) {
      data = process(response) { |document| document.css('entry') }

      attributes = %w(title location lat long thumbnail startdate)
      component = ->(attribute, entry) { entry.css(attribute).shift }

      data = data.each_with_object([]) do |entry, result|

        next unless attributes.all? { |attribute| component.(attribute, entry) }

        name_data = component.('title', entry)
        name = name_data.text =~ /^(.*)\sPub\sQuiz$/ && $1

        reference = entry.css('link').attr('href').value

        location_data = component.('location', entry)
        country, post_code, *address = location_data.text.split(', ').reverse

        city_data = component.('region', entry)
        city = city_data.text

        latitude_data = component.('lat', entry)
        latitude = latitude_data.text

        longitude_data = component.('long', entry)
        longitude = longitude_data.text

        image_url = entry.css('thumbnail').attr('url').value =~ /^\/\/(.*)/ && $1

        quiz_day_data = component.('startdate', entry)
        quiz_day = DateTime.parse(quiz_day_data.text).strftime('%a')

        location = {
          address: address.join(' '),
          city: city,
          country: country,
          region: nil,
          post_code: post_code,
          coordinates: {
            longitude: longitude,
            latitude: latitude
          }
        }

        result << {
          name: name,
          reference: reference,
          location: location,
          quiz_day: quiz_day,
          image_url: image_url
        }
      end
    }

    class << self
      CONFIG = {
        :base_url => 'http://questionone.com',
        :paginated => false,
        :source => 'QuestionOne',
        :scrape_status => {
          :find_all => :full,
        }
      }.freeze

      def config(key = nil)
        CONFIG[key]
      end

      def find_all
        status, source = config(:scrape_status)[__callee__], config(:source)

        collection = EDITIONS.inject([]) do |result, edition|
          result << Collection.(send_request("/#{edition}/events.atom"))
        end.flatten

        collection.map do |item|
          params = item.merge!({ scrape_status: status, source: source })
          QuizScraper::Quiz.new(params)
        end
      end
    end
  end

  private_constant(:QuestionOne)
end
