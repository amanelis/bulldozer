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

execution_start = Time.now
puts "Scrape::Koofers - All dependencies loaded"
puts "-----------------------------------------------------------------------------------"

# Proxy ip addresses
$PROXIES = [{:ip => '128.143.6.130', :port => '3128'}]

# User agents list
$AGENTS  = ['Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.6 (KHTML, like Gecko) Chrome/16.0.897.0 Safari/535.6',
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

# Number of threads to have running at one time.
$NUM_THREADS = 20

###################################
# Let the scrapage begin.
###################################

# Add all Universities to the queue for consumption by threads.
def queue_universities(states)
  # Start a queue to stare universities
  queue = Queue.new

  puts "Starting the queue process..."
  # Iterate through the states
  for state in states
    ua = $AGENTS[rand($AGENTS.length)]
    puts "Processing #{state.abbv}-----------------------------------------------------------"
    universities = Nokogiri::HTML(open("http://www.koofers.com/universities?s=#{state.abbv}"), ua).css('.univ_list a')
  
    # Iterate through the professors
    universities.each do |university|
      queue << {:university_url => "http://www.koofers.com#{university[:href]}", :state => state}
      puts "    queuing: #{university.content}"
    end
  end # for state in states
  puts "All Universites have been queued: #{queue.length}"
  queue
end

# Starts threads which will grab universities from the queue.
def start_threads(queue)
  # Where we will store the threads in process
  # Data results so we can compare to thread output
  threads = []

  $NUM_THREADS.times do
    # Create the Mechanize object for login in the user.
    # Select a new user agent, and proxy each iteration.
    ua = $AGENTS[rand($AGENTS.length)]
    pr = $PROXIES[rand($PROXIES.length)]
     
    threads << Thread.new(ua) do |ua|
      until queue.empty?
        begin
          data = queue.pop
          university_url = data[:university_url]
          state_obj = data[:state]
          
          # Right here lets create a university
          university_obj = University.create_from_url(university_url, state_obj, ua)
              
        rescue Exception => e
          p "****************************************************************"
          p "[FUCK] " + university_url + " failed: " + e.inspect
          p "****************************************************************"
          print e.backtrace.join("\n")
          next
        end
        
        puts "Processing #{university_url} [" + Document.all.count.to_s + " docs]"
        puts "******************************************************************************************************"
  
        # Iterate through the paginated exam pages.
        (1..1000).each do |page|
          begin
            # Perform the exams page scrape.
            exams_url = university_url + "study-materials?exams&p=#{page}"
            break unless scrape_exams_or_notes_page(exams_url, university_obj, "exam", ua)

          rescue Exception => e
            p "Failed to scrape exams page: " + exams_url
            p e.inspect
          end
        end # (1..1000).each do |page|
  
        # Iterate through the paginated notes pages.
        (1..1000).each do |page|
          begin
            # Perform the notes page scrape.
            notes_url = university_url + "study-materials?notes&p=#{page}"
            break unless scrape_exams_or_notes_page(notes_url, university_obj, "notes", ua)

          rescue Exception => e
            p "Failed to scrape notes page: " + url
            p e.inspect
          end
        end # (1..1000).each do |page|

      end # until queue.empty?
    end # threads << Thread.new do
  end # NUM_THREADS
  threads
end

def scrape_exams_or_notes_page(url, university_obj, type, ua)
  # Grab all the professors on each page
  documents = Nokogiri::HTML(open(url), ua).css('.title a')

  # Break if no docuemnet on data
  if documents.nil? || documents.empty? 
    return false
  end
  
  for document in documents
    begin
      document_url = "http://www.koofers.com" + document[:href]
      document_name = document.content

      # Now we want to follow the link on the document page to grab the professor name
      document_page = Nokogiri::HTML(open(document_url))
      professor_link = document_page.css('tr:nth-child(2) a')[0];
      isStaff = document_page.css('tr:nth-child(2) td:nth-child(2)')[0].content == "Staff"

      professor_obj = nil

      if isStaff
        # Do nothing.
      elsif professor_link.nil?
        p "[ERROR] Couldn't parse professors @ " + document_url
      else
        # Here is where we want to do the professor check and create the document professor
        # relation, store it in the database, and fuck koofers. 
        professor_url  = "http://www.koofers.com" + professor_link[:href]

        # Lets parse this shit out and save dat hoe
        professor_obj = Professor.create_from_url(professor_url, university_obj, ua)
        
        if professor_obj.first_name == "Rate"
          p "Failed to find professor name ~~~~> " + professor_url
        end
      end # for professor in professors

      path = "#{university_obj.slug}/#{isStaff ? "STAFF" : professor_obj.identifier}/"
      course_name = document_page.css('tr:nth-child(3) a')[0].content
      document_obj = Document.create!({:university_id => university_obj.id, :professor_id => isStaff ? nil : professor_obj.id, :url => document_url, :path => path, :course_name => course_name, :type => type})

      professor_name = isStaff ? "STAFF" : professor_obj.first_name + " " + professor_obj.last_name
      p "Added document @ " + document_obj[:url] + " with professor: " + professor_name + " for course: " + course_name
      
    rescue Exception => e
      p "Failed to scrape document ~~~~~> " + document_url
      print e.backtrace.first
      p e.inspect
    end
  end # for document in documents
  true
end

queue = queue_universities(State.all)
threads = start_threads(queue)

threads.collect { |t| t.join }
execution_finished = (Time.now - execution_start)
puts "Completed in #{execution_finished} -----------------------------------------"
puts "Total Documents: #{Document.all.count}"
puts "Total Professors: #{Professor.all.count}"
puts "Total Universities: #{University.all.count}"


