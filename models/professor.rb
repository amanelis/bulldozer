require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'

class Professor < ActiveRecord::Base  

  # Creates a Professor model from the given Koofers professor URL.
  def self.create_from_url(url)
    # TODO(Manelis) Check if this identifier exists.
    identifier = url.match(/-(\d+)\/$/)[1]

    # TODO(CH) Pass in the user agent / proxy.
    document = Nokogiri::HTML(open(url), 'Mac Mozilla')
    matches = document.at_css("title").text.match /(\w+) (\w+):/
    first_name = matches[1]
    last_name = matches[2]

    # Get the rating.
    rating = nil
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.request_post(url, "jq=InstructorDetailsPage::getCourseSummary&jqargs[]=-1&jqargs[]=json&jqloggedin=0")
      result = JSON.parse(response.body)
      fragment = Nokogiri::HTML.fragment(result['Data']['returnHTML'])
      rating = fragment.css('.summary_info div div span')[0].content
    end

    Professor.create!({:identifier => identifier, :first_name => first_name, :last_name => last_name, :rating => rating})
  end

end
