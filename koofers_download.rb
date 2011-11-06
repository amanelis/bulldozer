require 'rubygems'
require 'thread'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'aws/s3'
require 'rails/all'
require 'active_record' 
require './include/amazon.rb'
require File.expand_path(File.dirname(__FILE__) + '/db/connect')
require File.expand_path(File.dirname(__FILE__) + '/models/document')
require File.expand_path(File.dirname(__FILE__) + '/models/professor')
require File.expand_path(File.dirname(__FILE__) + '/models/state')
require File.expand_path(File.dirname(__FILE__) + '/models/university')

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
$NUM_THREADS = 2

# queue_document(documents obj array) #########################################################
def queue_documents(documents)
  # Start a queue to stare universities
  queue = Queue.new

  puts "Starting the queue process..."
  for document in documents
    ua = $AGENTS[rand($AGENTS.length)]
    puts "Processing #{document.url}-----------------------------------------------------------"
    queue << document
    puts "    queuing: #{document.id}, #{document.url}, #{document.university.name}"
  end
  puts "All documents have been queued: #{queue.length}"
  queue
end

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
        # consume the queue, returns a Document object
        doc = queue.pop
        
        # Create the url from koofers bullshit
        bucket = "frtbcdn"
        pdf_url = doc.url + '/koofer.pdf'
        filename = "document-#{doc.id}-#{DateTime.new(2009,9,5,15,45,50).strftime('%F')}.pdf"
        content = 'application/pdf'
        
        # Create the object for amazon
        a = AmazonS3Asset.new
        result = a.store_file(filename, pdf_url, bucket, content)
        p "RESULTS FROM UPLOAD -------------------------------------------"
        p result.inspect
      end # until queue.empty?
    end # threads << Thread.new do
  end
  threads
end

numbers = (1..100).collect {|x| x }
queue = queue_documents(Document.where(:id => numbers))
threads = start_threads(queue)
threads.collect { |t| t.join }







