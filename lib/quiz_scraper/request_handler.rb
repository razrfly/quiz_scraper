module QuizScraper
  module RequestHandler
    require 'httparty'

    def self.extended(client)
      client.include(HTTParty)
      client.base_uri(client.base_url)
    end

    private

    def send_request(url = '', method = :get)
      response = send(method, url)
      response.parsed_response
    end
  end
end
