module QuizScraper
  module PubQuizzer
    Table = ->(response) {
      table = process(response) { |document| document.css('#rounded-corner') }

      @headers ||= -> {
        headers = table.css('thead').css('tr').css('th').text and headers[0] = ''
        headers = headers.split("\n").map do |header|
          parameterize(header.strip, separator: ?_)
        end
        headers << 'reference'
      }.call

      @paginate_links ||= -> {
        links = table.css('tfoot').css('tr').css('td.rounded-foot-left').css('b')
        links.css('a[href]').each_with_object({}).with_index do |(link, result), i|
          result[i + 1] = link["href"].sub(%r(#{base_url}), '')
        end
      }.call

      trows = -> {
        trows = table.css('tbody').css('tr')
        trows.each_with_object([]) do |row, result|
          reference, data = row.css('a[href]').first['href'], row.text.split(?\n)
          data[2].sub!(/^.-./, '') # location fix
          result << (data[1..-1] << reference)
        end
      }.call

      { headers: @headers, trows: trows, paginate_links: @paginate_links }
    }
    private_constant(:Table)

    PubQuiz = ->(response) {
      table = process(response) { |document| document.css('#quiz-table') }
      trows = table.css('tr')
      text = ->(row) { row.css('td').first.text.sub(/^\s/, '') }
      link = ->(row) { row.css('td').css('a[href]').first['href'] }

      {
        'name' => text.(trows[0]), 'location' => text.(trows[1]),
        'post_code' => text.(trows[2]), 'phone' => text.(trows[3]),
        'website' => link.(trows[4]), 'frequency' => text.(trows[5]),
        'entry_fee' => text.(trows[6]), 'jackpot' => text.(trows[7]),
        'other_prices' => text.(trows[8]), 'max_team_size' => text.(trows[9]),
        'verified' => text.(trows[10])
      }
    }
    private_constant(:PubQuiz)

    class << self
      attr_accessor :base_url, :paginated

      PubQuizzer.base_url = 'http://www.pubquizzers.com'
      PubQuizzer.paginated = true

      def find_all(page)
        table = Table.(send_request('/search.php'))
        headers, paginate_links = table[:headers], table[:paginate_links]

        fetch_row = ->(row) {
          headers.each_with_object({}).with_index do |(key, result), index|
            result[key] = row[index]
          end
        }

        case page
        when :default
          table[:trows].each_with_object([]) do |row, result|
            result << fetch_row.(row)
          end
        when :all
          paginate_links.values.each_with_object([]) do |link, result|
            table = Table.(send_request(link))
            table[:trows].each { |row| result << fetch_row.(row) }
          end
        else
          table = Table.(send_request(paginate_links[page]))
          table[:trows].each_with_object([]) do |row, result|
            result << fetch_row.(row)
          end
        end
      end

      def find(reference)
        PubQuiz.(send_request(reference))
      end
    end
  end

  private_constant :PubQuizzer
end
