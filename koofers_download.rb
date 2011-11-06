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
require File.expand_path(File.dirname(__FILE__) + '/models/result')
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
$NUM_THREADS = 20

# Initiate the S3
$A = AmazonS3Asset.new

# Mutex this shit
$MUTEX = Mutex.new

# queue_document(documents obj array) #########################################################
def queue_documents(documents)
  # Start a queue to stare universities
  queue = Queue.new

  puts "Starting the queue process..."
  for document in documents
    ua = $AGENTS[rand($AGENTS.length)]
    puts "Processing #{document.url}-----------------------------------------------------------"
    
    document_professor_id = (document.professor.nil? ? (0) : (document.professor.id))
    document_university_id = (document.university.nil? ? (0) : (document.university.id))
    
    # Put the data in a queue as a hash for easy ready later
    data = {:document_object => document, 
            :document_professor_id => document_professor_id, 
            :document_university_id => document_university_id}

    # queue that hoe
    queue << data
    
    # pre processing output
    puts "    queuing: #{document.id}, #{document.url}, #{document.university.name}"
    puts "        professor: #{document_professor_id}" 
    puts "        university: #{document_university_id}"
  end
  puts "All documents have been queued: #{queue.length}"
  puts "-------------------------------------------------------------------------------"
  queue
end

def start_threads(queue)
  
  # Keep track of all documents
  total_docs_uploaded = 0
  
  # Where we will store the threads in process
  # Data results so we can compare to thread output
  threads = []

  $NUM_THREADS.times do
    # Create the Mechanize object for login in the user.
    # Select a new user agent, and proxy each iteration.
    ua = $AGENTS[rand($AGENTS.length)]
    pr = $PROXIES[rand($PROXIES.length)]
     
    threads << Thread.new {      
      until queue.empty?
        # consume the queue, returns a Document object
        data = queue.pop
        
        # Grab the document object out of the hash, well get the rest down below
        doc = data[:document_object]
        doc_prof = data[:document_professor_id]
        doc_univ = data[:document_university_id]
        
        puts "  --> Document#Object from Hash: #{doc.id}, prof: #{doc_prof}, :univ: #{doc_univ}"
        
        # Create the url from koofers bullshit
        bucket = "frtbcdn"
        pdf_url = doc.url + '/koofer.pdf'
        filename = "document-#{doc.id}-#{Time.now.strftime("%H%M%S-%Z-%Y-%d-%m")}.pdf"
        content = 'application/pdf'
        
        # Make the API call and store the document in S3, return 
        # the proper data neccesary to create a Result object in db
        # $MUTEX.synchronize do
          # Start the timer
          execution_start = Time.now
          
          # Make the call to the Class that will upload the document
          result = $A.store_file(filename, pdf_url, bucket, content)
        
          # Grab the brand new S3 url where our document is
          resulting_url = result[:s3_url] 
        
          # Update the attriobute on the document with the new shiny s3 url
          doc.update_attributes!(:s3_url => resulting_url)
        
          # Save the returning url as a result
          # r = Result.create!(:university_id => doc_univ.to_i, 
          #                    :professor_id => doc_prof, 
          #                    :base_url => doc.url, 
          #                    :amazon_url => resulting_url)
                           
          total_docs_uploaded += 1
          execution_finished = (Time.now - execution_start)
          puts "--> Download complete: #{doc.id}, #{doc_prof}, #{doc_univ} in: #{execution_finished} seconds"
        # end # $MUTEX.synchronize do
        puts "******************************* Total docs uploaded: #{total_docs_uploaded} *******************************"
      end # until queue.empty?
    } # threads << Thread.new do
  end # $NUM_THREADS
  threads
end # start_threads(queue)

numbers = (1..5).collect {|x| x }
queue = queue_documents(Document.where(:id => numbers))
threads = start_threads(queue)
threads.collect { |t| t.join }







