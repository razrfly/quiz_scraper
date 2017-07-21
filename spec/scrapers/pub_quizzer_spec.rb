require "spec_helper"

RSpec.describe 'QuizScraper::PubQuizzer' do
  let(:client) { QuizScraper::Scraper.new(:pub_quizzer) }

  it "finds all quizzes" do
    response = <<-BORK
      <html>
        <head></head>
        <body>
          <table id="rounded-corner" summary="Search Results">
            <thead>
              <tr>
                <th scope="col"><a><br>
                  Pub</a></th>
                <th scope="col"><a><br>
                  Location</a></th>
                <th scope="col"><a><br>
                  Frequency</a></th>
                <th scope="col"><a><br>
                  Distance</a></th>
                <th scope="col"><a><br>
                  Entry Fee</a></th>
                <th scope="col"><a><br>
                  Jackpot</a></th>
                <th scope="col"><a><br>
                  Post Code</a></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><a href="/pub-quiz/84/the-pilot-inn">The Pilot Inn<span></span></a></td>
                <td> - Greenwich, <a href="http://www.pubquizzers.com/london">London</a></td>
                <td>Tue @ 20:00</td>
                <td>0.7 miles</td>
                <td>£1.00</td>
                <td>£60</td>
                <td>SE10 0BE</td>
              </tr>
              <tr>
                <td><a href="/pub-quiz/149/the-marquess-tavern">The Marquess Tavern<span></span></a></td>
                <td> - Canonbury, <a href="http://www.pubquizzers.com/london">London</a></td>
                <td>Tue @ 20:00</td>
                <td>4.9 miles</td>
                <td>£2.00</td>
                <td>£80</td>
                <td>N1 2TB</td>
              </tr>
            </tbody>
          </table>
        </body>
      </html>
    BORK

    stub_request(:get, "http://www.pubquizzers.com/search.php").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, :body => response, headers: {})

    pubs = client.find_all
    pub = pubs.first

    expect(pubs.size).to eq 2

    expect(pub.name).to eq("The Pilot Inn")
    expect(pub.reference).to eq("/pub-quiz/84/the-pilot-inn")
    expect(pub.raw_data).to include(
      "pub"=>"The Pilot Inn",
      "location"=>"Greenwich, London",
      "frequency"=>"Tue @ 20:00",
      "distance"=>"0.7 miles",
      "entry_fee"=>"£1.00",
      "jackpot"=>"£60",
      "post_code"=>"SE10 0BE",
      "reference"=>"/pub-quiz/84/the-pilot-inn"
    )
  end

  it "finds a quiz by reference" do
    response = <<-BORK
      <table id="quiz-table">
        <tbody>
          <tr>
            <td> The Pilot Inn</td>
          </tr>
          <tr>
            <td> Greenwich, London, UK</td>
          </tr>
          <tr>
            <td> SE10 0BE</td>
          </tr>
          <tr>
            <td> 020 8858 5910</td>
          </tr>
          <tr>
            <td><a href="http://www.pilotgreenwich.co.uk" target="_blank">pilotgreenwich.co.uk</a></td>
          </tr>
          <tr>
            <td> Tuesday, Weekly @ 20:00</td>
          </tr>
          <tr>
            <td> £1.00</td>
          </tr>
          <tr>
            <td> £60</td>
          </tr>
          <tr>
            <td> Cash</td>
          </tr>
            <tr>
            <td> 10 People Per Team<br></td>
          </tr>
          <tr>
            <td> Verified: By Phone<br></td>
          </tr>
        </tbody>
      </table>
    BORK

    stub_request(:get, "http://www.pubquizzers.com/pub-quiz/84/the-pilot-inn").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, :body => response, headers: {})

    pub = client.find('/pub-quiz/84/the-pilot-inn')

    expect(pub.name).to eq("The Pilot Inn")
    expect(pub.reference).to eq("/pub-quiz/84/the-pilot-inn")
    expect(pub.raw_data).to include(
      "name"=>"The Pilot Inn",
      "location"=>"Greenwich, London, UK",
      "post_code"=>"SE10 0BE",
      "phone"=>"020 8858 5910",
      "website"=>"http://www.pilotgreenwich.co.uk",
      "frequency"=>"Tuesday, Weekly @ 20:00",
      "entry_fee"=>"£1.00",
      "jackpot"=>"£60",
      "other_prices"=>"Cash",
      "max_team_size"=>"10 People Per Team",
      "verified"=>"Verified: By Phone"
    )
  end
end
