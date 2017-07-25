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
      host = opts.delete(:host)

      begin
        if host.nil?
          send(method, url, opts)
        else
          HTTParty.send(method, (host + url), opts)
        end

        response.success? ? response.parsed_response : raise(ResponseError)
      rescue URI::Error
        raise(ResponseError)
      end
    end
  end
end
