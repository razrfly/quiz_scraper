class PubQuizzer
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

  class << self
    attr_accessor :base_url, :paginated

    PubQuizzer.base_url = 'http://www.pubquizzers.com'
    PubQuizzer.paginated = true

    private

    def find_all(page)
      case page
      when :default
        # logic when called without and page param
      when :all
        # logic when need to fetch data from whole table
      else
        # logic for specific page
      end
    end
  end
end
