require 'rubygems'
require 'open-uri'
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

$NUM_PROCESSES = 25

def process_documents(universities)
  ActiveRecord::Base.establish_connection(
    :adapter  => "mysql", 
    :host     => "localhost", 
    :username => "root", 
    :password => "", 
    :database => "koofers",
    :pool     => 25
  )
  
  # Initiate the S3
  a = AmazonS3Asset.new

  # Keep track of all documents
  total_docs_uploaded = 0
  error_count = 0
  
  universities.each do |university|
    puts "Starting the queue process..."
    for document in university.documents
      puts "Processing #{document.url}-----------------------------------------------------------"

      document_professor_id = (document.professor.nil? ? (0) : (document.professor.id))
      document_university_id = (document.university.nil? ? (0) : (document.university.id))

      # Put the data in a queue as a hash for easy ready later
      data = {:document_object => document, 
              :document_professor_id => document_professor_id, 
              :document_university_id => document_university_id}

      # pre processing output
      puts "    queuing: #{document.id}, #{document.url}, #{document.university.name}"
      puts "        professor: #{document_professor_id}" 
      puts "        university: #{document_university_id}"
      
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
      # Start the timer
      execution_start = Time.now

      begin
        # Make the call to the Class that will upload the document
        result = a.store_file(filename, pdf_url, bucket, content)

        # Grab the brand new S3 url where our document is
        resulting_url = result[:s3_url] 

        # Update the attriobute on the document with the new shiny s3 url
        doc.update_attributes!(:s3_url => resulting_url)
      
        puts "RESULT: #{resulting_url}"

        # Save the returning url as a result
         r = Result.create!(:university_id => doc_univ.to_i, 
                            :professor_id => doc_prof, 
                            :base_url => doc.url, 
                            :amazon_url => resulting_url)
         total_docs_uploaded += 1
      rescue Exception => e
        error_count += 1
        puts "ERROR[#{error_count}] --> Unable to download the document and store it"
      end
      execution_finished = (Time.now - execution_start)
      puts "--> Download complete: #{doc.id}, #{doc_prof}, #{doc_univ} in: #{execution_finished} seconds"
      puts "******************************* Total docs uploaded: #{total_docs_uploaded} *******************************"
    end
  end
  puts "Process Completed with #{total_docs_uploaded} and #{error_count} failed to upload-------------------------------------------------------------------------------"
end


def import
    start_time = Time.now
    ids = (1..25).to_a
    universities = University.where(:id => ids)
    process_ids = []
    chunk_size = (universities.count / Float($NUM_PROCESSES)).ceil
    
    (0...$NUM_PROCESSES).each do |i|
      start = i * chunk_size
      finish = (i + 1) * chunk_size
      
      chunk = universities.slice(start...finish)
      break if chunk.nil?
      
      # Fork
      child_id = Kernel.fork
      
      if child_id.nil?        
        puts "  --> CHILD"
        process_documents(chunk)
        return  
      else
        puts "PARENT: #{child_id}"
        process_ids << child_id
      end
    end
    
    process_ids.collect { |p| Process.waitpid(p) }
    finished = (Time.now - start_time) / 60.0
    puts "FINISHED in #{finished} seconds------------------------------------"
end

# Start the beast
import
