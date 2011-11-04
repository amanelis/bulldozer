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
      url = "http://koofers.com#{base_university_url}study-materials?exams&p=#{page}"
      begin
        documents = Nokogiri::HTML(open(url), UserAgent.generate_user_agent).css('.title a')
      rescue Timeout::Error => e
        puts "Error code: #{e.errno}"
        puts "Error message: #{e.error}"
        puts "Looks like this one failed, going to next..."
        next
      end

      if documents.blank? || documents.nil? || documents.empty?
        break
      else
        documents.each do |document|
          puts "DOWNLOADING  ##########################################"

          hack_url  = "http://koofers.com#{document['href']}/koofer.pdf&printButton=Yes&sendViewerEvents=Yes"
          hack_cmd  = "wget -r -P ./exams/#{path} #{hack_url}"
          wget_output = system(hack_cmd)
          # puts "DOCUMENT: #{path}"

          docs = docs + 1
        end
        puts "On page #{page}..."
      end
    end




  end # universities.each do |university|
end # for state in states




