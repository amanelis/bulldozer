require 'rubygems'
require 'thread'
require 'json'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
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
agents  = ['Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.6 (KHTML, like Gecko) Chrome/16.0.897.0 Safari/535.6',
           'Mozilla/5.0 (X11; U; Linux i686; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.84 Safari/534.13',
           'Mozilla/5.0 (X11; U; CrOS i686 0.9.128; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.341 Safari/534.10',
           'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 1.0.3705; .NET CLR 1.1.4322)',
           'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; Media Center PC 6.0; InfoPath.2; MS-RTC LM 8)',
           'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6',
           'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)',
           'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)',
           'Googlebot/2.1 ( http://www.googlebot.com/bot.html)',
           'Mozilla/2.0 (compatible; Ask Jeeves)',
           'Msnbot-Products/1.0 (+http://search.msn.com/msnbot.htm)'] 

# States array to limit calls to koofers  
states = []         
states << State.find_by_abbv('TX')
states << State.find_by_abbv('AL')

# Number of threads to have running at one time.
NUM_THREADS = 3

# Where we will store the threads in process
# Data results so we can compare to thread output
threads = results = []

# Keep track of data we iterate through
total_documents = total_professors = total_universities = 0

# Start a queue to stare universities
queue = Queue.new

###################################
# Let the scrapage begin.
###################################

puts "Starting the queue process..."
# Iterate through the states
for state in states
  ua = agents[rand(agents.length)]
  puts "Processing #{state}-----------------------------------------------------------"
  universities = Nokogiri::HTML(open("http://www.koofers.com/universities?s=#{state.abbv}"), ua).css('.univ_list a')

  # Iterate through the professors
  universities.each do |university|
    queue << "http://www.koofers.com#{university[:href]}"
    puts "    queuing: #{university.content}"
  end
end # for state in states

puts "All Universites have been queued: #{queue.length}"

NUM_THREADS.times do
  # Create the Mechanize object for loggin in the user
  # Select a new user agent, and proxy each iteration
  ua = agents[rand(agents.length)]
  pr = proxies[rand(proxies.length)]
   
  threads << Thread.new(ua) do |ua|
    until queue.empty?
      university_url = queue.pop
      
      # Right here lets create a university
      university_obj = University.create_from_url(university_url, state, ua)

      # Here is the big iteration on the Professors, could take a while
      # Definitely need to thread these iterations out. We will try to paginate
      # Through as many pages as possible.
      (1..1000).each do |page|
        documents_url = "http://www.koofers.com/#{university_obj.slug}/study-materials?exams&p=#{page}"

        documents = Nokogiri::HTML(open(documents_url), ua).css('.title a')

        if documents.nil? || documents.empty? 
          break
        else
      
          for document in documents
            p "DOCUMENTS FOR: #{university_obj.slug}"
            p document[:href]
            p document.content
        
          end # for document in documents
        end
      end # (1..1000).each do |page|
    end # until queue.empty?
  end # threads << Thread.new do
end # NUM_THREADS

threads.collect { |t| t.join }
p "finished"
