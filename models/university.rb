class University < ActiveRecord::Base  
  belongs_to :state
  has_many :professors

  def self.create_from_url(url, state, ua)
    slug = url.match(/com\/(.+)\//)[1]

    # Ensure the slug is unique before scraping the page.
    existing = University.find_by_slug(slug)
    return existing unless existing.nil?

    # Find the name of the university.
    document = Nokogiri::HTML(open(url), ua)
    name = document.css(".header_container .pale_text")[0].content

    University.create!({:name => name, :slug => slug, :state_id => state.id})
  end

end
