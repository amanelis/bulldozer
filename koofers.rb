require 'rubygems'
require 'json'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'uri'
require 'net/http'
require 'yajl/http_stream'
require 'active_record'
require 'rails/all'
require File.expand_path(File.dirname(__FILE__) + '/db/connect')
require File.expand_path(File.dirname(__FILE__) + '/models/document')
require File.expand_path(File.dirname(__FILE__) + '/models/professor')
require File.expand_path(File.dirname(__FILE__) + '/models/state')
require File.expand_path(File.dirname(__FILE__) + '/models/university')

puts "Scrape::Koofers - All dependencies loaded"
puts "-----------------------------------------------------------------------------------"

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
states = ["TX", "WY"]

# Number of threads to have running at one time.
NUM_THREADS = 3

# Where we will store the threads in process
# Data results so we can compare to thread output
threads = results = []

# Keep track of data we iterate through
total_documents = total_professors = total_universities = 0

# Create the Mechanize object for loggin in the user
# Select a new user agent, and proxy each iteration
ua = agents[rand(agents.length)]
pr = proxies[rand(proxies.length)]

queue = Queue.new

puts "Starting the queue process..."
# Iterate through the states
for state in states
  puts "Processing #{state}-----------------------------------------------------------"
  universities = Nokogiri::HTML(open("http://www.koofers.com/universities?s=#{state}"), ua).css('.univ_list a')

  # Iterate through the professors
  universities.each do |university|
    queue << "http://www.koofers.com#{university[:href]}"
    puts "    queuing: #{university.content}"
  end
end # for state in states
puts "All Universites have been queued: #{queue.length}"

NUM_THREADS.times do
  threads << Thread.new do
    until queue.empty?
      begin
        university_url = queue.pop    
      rescue Exception
        p "*******************************************************************************************************"
        p "   " + university_url + " failed."
        p "*******************************************************************************************************"
        break
      end

      university_professors = university_url + "professors"
      university_exams      = university_url + "study-materials?exams"

      # Here is the big iteration on the Professors, could take a while
      # Definitely need to thread these iterations out. We will try to paginate
      # Through as many pages as possible.
      (1..1000).each do |page|
        documents_url = university_exams + "&p=#{page}"

        # p Thread.current.object_id.to_s + ": " + documents_url

        # Grab all the professors on each page
        documents = Nokogiri::HTML(open(documents_url), ua).css('.title a')

        # Break if no professors on data
        if documents.nil? || documents.empty? 
          break
        end

        # Now lets start the Iteration on the professors, this is going to be a lot of data
        # So here we want to get each document, then follow through the professor link, check
        # the database if professor exists, create the professor and insert the document.
        for document in documents
          document_url = "http://www.koofers.com" + document[:href]
          document_name = document.content
          
          p "   " + document_name

          # Now we want to follow the link on the document page to grab the professor name
          professor_document_data = Nokogiri::HTML(open(document_url)).css('tr:nth-child(2) a')
          if professor_document_data.nil?
            p "Professor not found, fuck"
          else
            # Here is where we want to do the professor check and create the document professor
            # relation, store it in the database, and fuck koofers.
            
            professor_document_data.each do |name|
              professor_name = name.content
              professor_url  = name[:href]
              p "       " + professor_name
            end # professor_document_data.each do |name|
          end # for professor in professors
        end # for document in documents
      end # (1..1000).each do |page|
    end # until queue.empty?
  end # threads << Thread.new do
end # NUM_THREADS


threads.collect { |t| t.join }
p "finished"