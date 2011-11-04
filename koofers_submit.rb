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
states  = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA",
           "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR",
           "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]

# Genres for testing on console instead of 
# Hitting koofers everytime.           
genres = ["breaks", "chill-out", "deep-house", "drum-and-bass", "dubstep", "electro-house", 
          "electronica", "funk-r-and-b", "glitch-hop", "hard-dance", "hardcore-hard-techno", "hip-hop", 
          "house", "indie-dance-nu-disco", "minimal", "pop-rock", "progressive-house", "psy-trance", 
          "reggae-dub", "tech-house", "techno", "trance"]

# Where we will store the threads in process
# Data results so we can compare to thread output
threads, results = []


# doc = Nokogiri::HTML(open('http://www.koofers.com/files/exam-mxbsglpps0/')).css('#doc_view img')

login_url = "http://www.soundcloud.com/login"
agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'
page = agent.get(login_url)
form = page.form_with(:id => 'login-form')

form.username = 'amanelis@gmail.com'
form.password = 'alex18'
page = form.submit
puts page.body


# Create the Mechanize object for loggin in the user
# Select a new user agent, and proxy each iteration
# ua = agents[rand(agents.length)]
# pr = proxies[rand(proxies.length)]
# 
# # Create the mechanize object
# login = Mechanize.new
# 
# # Set the user agent in mechanize
# login.user_agent_alias = ua
# 
# # Set the page to access
# page = login.get("http://www.soundcloud.com/login")
# 
# # Submit the user info
# url = URI.parse("http://soundcloud.com/login")
# request  = Net::HTTP.post_form(url, {"site-username" => 'amanelis@gmail.com', "site-password" => 'alex18'})
# response = request.body
# 
# p response.inspect

# login_page = agent.click(homepage.link_with(:text => "Search"))

# search_form = page.form_with(:name => "f")
# search_form.field_with(:name => "email").value = "redbull50418@usa.com"
# search_results = agent.submit(search_form)
# puts search_results.body




=begin
for state in genres
  puts "Processing #{state}\n"

  # Select a new user agent, and proxy each iteration
  ua = agents[rand(agents.length)]
  pr = proxies[rand(proxies.length)]

  # Create the mechanize object
  agent = Mechanize.new

  # Set the user agent in mechanize
  agent.user_agent_alias = ua
end
=end




# require 'rubygems'
# require 'mechanize'
# require 'logger'
# 
# agent = Mechanize.new { |a| a.log = Logger.new("mech.log") }
# agent.user_agent_alias = 'Mac Safari'
# page = agent.get("http://www.google.com/")
# search_form = page.form_with(:name => "f")
# search_form.field_with(:name => "q").value = "Hello"
# search_results = agent.submit(search_form)
# puts search_results.body

