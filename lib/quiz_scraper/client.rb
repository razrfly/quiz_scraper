module QuizScraper
  class Client
    attr_reader :client

    def initialize(client)
      raise ArgumentError unless client.is_a?(Class)
      @client = client and extend_client
    end

    def find_all(params = {})
      page = extract_page_param(params) if client.paginated
      page && client.send(:find_all, page) || client.send(:find_all)
    end

    private

    def extract_page_param(params)
      return :default if params.empty?
      param = params.fetch(:page, nil)
      param &&= begin
        case temp = param
        when :all, 'all' then temp.to_sym
        when String then temp =~ /^\d+$/ and $&.to_i
        when Integer then temp
        end
      end
      param || :default
    end

    def extend_client
      client.tap do |client|
        require 'active_support/inflector'
        client.extend(QuizScraper::RequestHandler)
        client.extend(QuizScraper::RequestProcessor)
        client.extend(ActiveSupport::Inflector)
      end
    end
  end
end
