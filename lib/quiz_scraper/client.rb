module QuizScraper
  class Client
    attr_reader :client

    def initialize(client)
      raise ArgumentError unless client.is_a?(Class)
      @client = client and extend_client
    end

    def find_all(params = {})
      # delegates everything to client something like:
      # client.send(:find_all, params)
    end

    private

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
