module QuizScraper
  module RequestHandler
    require 'httparty'

    def self.extended(client)
      client.include(HTTParty)
    end

    private

    def send_request(url = '', method = :get)
      response = send(method, url)
      response.parsed_response
    end
  end
end
