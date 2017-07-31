module QuizScraper
  module RequestHandler
    require 'httparty'

    ResponseError = Class.new(StandardError)

    def self.extended(scraper)
      scraper.include(HTTParty)
      scraper.base_uri(scraper.base_url)
    end

    private

    def send_request(url = '', method = :get, **opts)
      host = opts.delete(:host)

      begin
        response =
          host.nil? ?
            send(method, url, opts) : HTTParty.send(method, (host + url), opts)

        raise(ResponseError) unless response.success?

        response.parsed_response
      rescue URI::Error
        raise(ResponseError)
      end
    end
  end
end
