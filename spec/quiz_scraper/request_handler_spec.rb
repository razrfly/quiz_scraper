require "spec_helper"

RSpec.describe QuizScraper::RequestHandler do
  let(:namespace) { QuizScraper::RequestHandler }
  let(:adapter) { QuizScraper::Scraper.new(:pub_quizzer) }
  let(:scraper) { adapter.scraper }

  it "has defined UndefinedScraperError class" do
    expect(namespace.constants).to include(:ResponseError)
  end

  context "when module 'extended' callback invoked" do
    it "includes HTTParty module into related scraper" do
      expect(scraper.included_modules.include?(HTTParty)).to be_truthy
    end

    it "expects to set up correct base_uri acquired from scraper" do
      expect(scraper.base_uri).to eq("http://www.pubquizzers.com")
    end
  end

  context "when +send_request+ method invoked" do
    let(:headers) {
      {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      }
    }

    it "uses 'get' request method by default" do
      stub_request(:get, "http://www.pubquizzers.com/test").
        with(headers: headers).
          to_return(status: 200, :body => "GET method by default", headers: {})

      body = scraper.instance_eval { send_request("/test") }

      expect(body).to eq("GET method by default")
    end

    it "allows for using another HTTP protocol methods" do
      stub_request(:post, "http://www.pubquizzers.com/test").
        with(headers: headers).
          to_return(status: 200, :body => "POST method allowed", headers: {})

      body = scraper.instance_eval { send_request("/test", :post) }

      expect(body).to eq("POST method allowed")
    end

    it "allows for setting up specific host" do
      stub_request(:post, "http://www.hostchanged.com/test").
        with(headers: headers).
          to_return(status: 200, :body => "Changing host allowed", headers: {})

      body = scraper.instance_eval {
        send_request("/test", :post, host: 'http://www.hostchanged.com')
      }

      expect(body).to eq("Changing host allowed")
    end
  end
end
