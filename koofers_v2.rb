require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'thread'
require 'json'
require 'mysql'
require 'active_record'
require 'net/http'
require 'mechanize'

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
threads = []

# Data results so we can compare to thread output
results = []

for state in genres
  puts "Processing #{state}\n"
  
  # Set and initialize threads
  threads << Thread.new(state) { |page| 
    
    puts "Inside thread: #{page}"
    puts Thread.current.object_id
    puts Thread.current.inspect
    # Thread.list.each {|t| p t}
    puts ""
  
    # Select a new user agent, and proxy each iteration
    ua = agents[rand(agents.length)]
    pr = proxies[rand(proxies.length)]
  
    # Create the mechanize object
    agent = Mechanize.new
  
    # Set the user agent in mechanize
    agent.user_agent_alias = ua
  
    # Set the proxy info in mechanize
    # Try and set it via Net::HTTP:SOCKS
    # agent.set_proxy(pr[:ip], port[:port])    
    # uri = URI.parse('http://staging.console.fm/dubstep')
    # Net::HTTP.SOCKSProxy('128.208.04.198', 2124).start(uri.host, uri.port) do |http|
    #   http.get(uri.path)
    # end
  
    begin
      doc = agent.get("http://staging.console.fm/#{page}")
    rescue Mechanize::ResponseCodeError => e
      puts "Mechanize::ResponseCodeError"
      puts "Error: #{e.inspect}"
    rescue Net::HTTPServiceUnavailable => e
      puts "Net::HTTPServiceUnavailable"
      puts "Error: #{e.inspect}"
    end  
    
    results << ({:thread_id => Thread.current.object_id, :thread => Thread.current.inspect, :page => page, :state => state})
  }
end

# Join the threads
begin 
  threads.each { |t| t.join }
rescue Net::HTTP::Persistent::Error => e
  puts "Net::HTTP::Persistent::Error"
  puts "Error Message: #{e.inspect}"
end

