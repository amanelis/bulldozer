require 'rubygems'
require 'json'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'net/http'
require 'uri'

# Proxy ip addresses
proxies = [{:ip => '128.143.6.130', :port => '3128'}]

# User agents list
agents  = ['Windows IE 6',
           'Windows IE 7',
           'Mac Mozilla'] 

# States array to limit calls to koofers           
# states  = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA",
#            "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR",
#            "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
states = ["TX"]

# Where we will store the threads in process
# Data results so we can compare to thread output
threads, results = []

# Create the Mechanize object for loggin in the user
# Select a new user agent, and proxy each iteration
ua = agents[rand(agents.length)]
pr = proxies[rand(proxies.length)]

# Iterate through the states
for state in states
  puts "Processing #{state}-----------------------------------------------------------"
  universites = Nokogiri::HTML(open("http://www.koofers.com/universities?s=#{state}"), ua).css('.univ_list a')
  
  # Iterate throught the professors
  universites.each do |university|
    university_url        = "http://www.koofers.com#{university[:href]}"
    university_professors = university_url + "professors"
    university_exams      = university_url + "study-materials?exams"

    # Here is the big iteration on the Professors, could take a while
    # Definitely need to thread these iterations out. We will try to paginate
    # Through as many pages as possible.
    (1..1000).each do |page|
      professors_url = university_professors + "&p=#{page}"

      # Grab all the professors on each page
      professors = Nokogiri::HTML(open(professors_url), ua).css('.title a')
      
      # Break if no professors on data
      break if professors.blank? || professors.nil? || professors.empty?
      
      # Now lets start the Iteration on the professors, this is going to be a lot of data
      for professor in professors
        
      end # for professor in professors
    end # (1..1000).each do |page|
  end # universities.each do |university|
end # for state in states




