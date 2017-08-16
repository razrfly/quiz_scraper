module QuizScraper
  module PubQuizzer
    require "quiz_scraper/utils/country_mapper"

    Collection = ->(response) {
      data = process(response) { |document| document.css('#rounded-corner') }

      headers = -> {
        headers = data.css('thead').css('tr').css('th').text and headers[0] = ''
        headers = headers.split("\n").map do |header|
          parameterize(header.strip, separator: ?_)
        end
        headers << 'reference'
      }.call

      paginate_links = -> {
        links = data.css('tfoot').css('tr').css('td.rounded-foot-left').css('b')
        links.css('a[href]').each_with_object({}).with_index do |(link, result), i|
          result[i + 1] = link["href"].sub(%r(#{base_url}), '')
        end
      }.call

      venues = -> {
        trows = data.css('tbody').css('tr')
        venues = trows.each_with_object([]) do |row, result|
          # fetch data from venue row and fix for location
          data = row.css('td').map(&:text) and data[1].sub!(/^.-./, '')

          # create reference for further use and add it to data
          reference = row.css('a[href]').first['href'] and data << reference

          raw_data = headers.each_with_object({}).with_index do |(key, temp), index|
            temp[key] = data[index]
          end

          result << {
            name: raw_data['pub'],
            reference: raw_data['reference'],
            raw_data: raw_data
          }
        end
      }.call

      { headers: headers, venues: venues, paginate_links: paginate_links }
    }
    private_constant(:Collection)

    PubQuiz = ->(response, reference) {
      content = process(response) { |document| document.css('#content') }

      trows = content.css('#quiz-table').css('tr')
      coordinates = content.css('.quiz-right').css('iframe').attr('src')
      image = content.css('.quiz-left').css('img').attr('src')

      text = ->(row) { row.css('td').first.text.sub(/^\s/, '') }
      link = ->(row) { row.css('td').css('a[href]').first['href'] }

      headers = %w(name location post_code phone website frequency entry_fee
      jackpot other_prices max_team_size verified)

      raw_data = headers.each_with_object({}).with_index do |(key, temp), index|
        temp[key] = key == 'website' ? link.(trows[index]) : text.(trows[index])
      end

      post_code, country, city, region, address =
        raw_data['post_code'], *raw_data['location'].split(', ').reverse

      latitude, longitude = coordinates.value =~ /lat=(.*)&lon=(.*)/ && [$1, $2]

      quiz_day = raw_data['frequency'] =~ /^(\w+),\s(\w+)(\W+)(\d{1,2}:\d{2})$/ && $1

      image_url = image.value =~ /(\/images\/pubs\/.*.jpg$)/ && $1
      image_url &&= PubQuizzer.base_url + image_url

      location = {
        address: address,
        city: city,
        country: map_country(country),
        region: region,
        post_code: post_code,
        coordinates: {
          longitude: longitude,
          latitude: latitude
        }
      }

      {
        name: raw_data['name'],
        reference: reference,
        location: location,
        quiz_day: quiz_day,
        image_url: image_url,
        raw_data: raw_data
      }
    }
    private_constant(:PubQuiz)

    class << self
      attr_accessor :base_url, :paginated, :scrape_status

      PubQuizzer.base_url = 'http://www.pubquizzers.com'
      PubQuizzer.paginated = true
      PubQuizzer.scrape_status = {
        :find_all => :partial,
        :find => :full
      }

      def find_all(page)
        collection = Collection.(send_request('/search.php'))
        status = scrape_status[__callee__]

        case page
        when :default
          collection[:venues].each_with_object([]) do |venue, result|
            params = venue.merge!({ scrape_status: status })
            result << QuizScraper::Quiz.new(params)
          end
        when :all
          paginate_links = collection[:paginate_links]

          paginate_links.values.each_with_object([]) do |link, result|
            collection = Collection.(send_request(link))

            collection[:venues].each do |venue|
              params = venue.merge!({ scrape_status: status })
              result << QuizScraper::Quiz.new(params)
            end
          end
        else
          paginate_links = collection[:paginate_links]
          collection = Collection.(send_request(paginate_links[page]))

          collection[:venues].each_with_object([]) do |venue, result|
            params = venue.merge!({ scrape_status: status })
            result << QuizScraper::Quiz.new(params)
          end
        end
      end

      def find(reference)
        begin
          params = PubQuiz.(send_request(reference), reference)
          params.merge!({ scrape_status: scrape_status[__callee__] })
        rescue QuizScraper::RequestHandler::ResponseError
          params = {scrape_status: :partial}
        end

        QuizScraper::Quiz.new(params)
      end

      private

      def map_country(country)
        QuizScraper::CountryMapper.map(country)
      end
    end
  end

  private_constant(:PubQuizzer)
end
