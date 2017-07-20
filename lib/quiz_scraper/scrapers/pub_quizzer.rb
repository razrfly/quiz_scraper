module QuizScraper
  module PubQuizzer
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
      table = process(response) { |document| document.css('#quiz-table') }
      trows = table.css('tr')
      text = ->(row) { row.css('td').first.text.sub(/^\s/, '') }
      link = ->(row) { row.css('td').css('a[href]').first['href'] }

      headers = %w(name location post_code phone website frequency entry_fee
      jackpot other_prices max_team_size verified)

      raw_data = headers.each_with_object({}).with_index do |(key, temp), index|
        temp[key] = key == 'website' ? link.(trows[index]) : text.(trows[index])
      end

      {
        name: raw_data['name'],
        reference: reference,
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

        case page
        when :default
          collection[:venues].each_with_object([]) do |venue, result|
            result << QuizScraper::Quiz.new(
              venue, source: self, origin: __callee__
            )
          end
        when :all
          paginate_links = collection[:paginate_links]

          paginate_links.values.each_with_object([]) do |link, result|
            collection = Collection.(send_request(link))

            collection[:venues].each do |venue|
              result << QuizScraper::Quiz.new(
                venue, source: self, origin: __callee__
              )
            end
          end
        else
          paginate_links = collection[:paginate_links]
          collection = Collection.(send_request(paginate_links[page]))

          collection[:venues].each_with_object([]) do |venue, result|
            result << QuizScraper::Quiz.new(
              venue, source: self, origin: __callee__
            )
          end
        end
      end

      def find(reference)
        PubQuiz.(send_request(reference))
      end
    end
  end

  private_constant(:PubQuizzer)
end
