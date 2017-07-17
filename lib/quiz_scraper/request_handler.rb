module QuizScraper
  module RequestHandler
    require 'httparty'

    ResponseError = Class.new(StandardError)

    def self.extended(client)
      client.include(HTTParty)
      client.base_uri(client.base_url)
    end

    private

    def send_request(url = '', method = :get, **opts)
      response = send(method, url, opts)
      raise(ResponseError) unless response.success?
      response.parsed_response
    end
  end
end
