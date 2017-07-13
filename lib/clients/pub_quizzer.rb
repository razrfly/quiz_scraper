class PubQuizzer
  Table = ->(response) {
    # Here will be (already is) nokogirii parsing fun
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
