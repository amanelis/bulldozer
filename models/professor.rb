require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'

class Professor < ActiveRecord::Base  
  belongs_to :university
  has_many :documents
  has_one :department

  # Creates a Professor model from the given Koofers professor URL.
  def self.create_from_url(url, university, ua)
    identifier = Integer(url.match(/-(\d+)\/$/)[1])

    existing = Professor.find_by_identifier(identifier)
    return existing unless existing.nil?

    # TODO(CH) Pass in the user agent / proxy.
    document = Nokogiri::HTML(open(url), ua)
    matches = document.at_css("#full_name").text.match /(.+) (.+)/
    first_name = matches[1]
    last_name = matches[2]

    # Get the rating.
    rating = nil
    uri = URI.parse(url)
    begin
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.request_post(url, "jq=InstructorDetailsPage::getCourseSummary&jqargs[]=-1&jqargs[]=json&jqloggedin=0")
        result = JSON.parse(response.body)
        fragment = Nokogiri::HTML.fragment(result["Data"]["returnHTML"])
        rating = Float(fragment.css(".summary_info div div span")[0].content)
      end
    rescue Exception
      p "[WARN] Failed to parse ratings for " + url
    end

    prof = Professor.create!({:identifier => identifier, :first_name => first_name, :last_name => last_name, :rating => rating, :university_id => university.id, :url => url})
    prof
  end

end
