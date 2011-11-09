require 'rubygems'
require 'thread'
require 'json'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'net/http'
require 'active_record'
require 'rails/all'
require File.expand_path(File.dirname(__FILE__) + '/models/document')
require File.expand_path(File.dirname(__FILE__) + '/models/professor')
require File.expand_path(File.dirname(__FILE__) + '/models/state')
require File.expand_path(File.dirname(__FILE__) + '/models/result')
require File.expand_path(File.dirname(__FILE__) + '/models/university')

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql", 
  :host     => "localhost", 
  :username => "root", 
  :password => "", 
  :database => "koofers",
  :pool     => 75
)

$NUM_PROCESSES = 50
download_error = 0
download_success = 0
total_time = 0.0
threads = []

# documents = Document.find(:all, :conditions => ["title IS NOT NULL"], :order => 'id ASC')
# q = Queue.new
# documents.collect { |d| q << d }
# 
# 
# 25.times do
#   threads << Thread.new(q) { |q| 
#     
#       until q.empty?
#           doc = q.pop
#           
#           execution_start = Time.now
#           begin
#             url = doc.url
#             page = Nokogiri::HTML(open(url))
#           rescue Exception
#             puts "[ERROR] Could not open the URL"
#             puts ""
#             download_error += download_error
#             next
#           end
#   
#           page_text = page.css('.content_header_full').first
#           text = page_text.content.match(/(.*) for/)
#           title = text.nil? ? "Document" : text[1]
#   
#           # Now save the attribute
#           doc.update_attributes!(:title => title) 
#           download_success += download_success
#   
#           execution_finished = (Time.now - execution_start)
#           total_time += execution_finished
#           puts "[SUCCESS] Updated title on document: #{doc.id} in #{execution_finished}"
#           puts ""
#       end #until empty
#   }
#   
# end
# # Join these hoes
# threads.each { |t|  t.join }

def process_documents(documents)    
    for doc in documents
      begin
        url = doc.url
        page = Nokogiri::HTML(open(url))
      rescue Exception
        puts "[ERROR] Could not open the URL"
        puts ""
        next
      end

      page_text = page.css('.content_header_full').first
      text = page_text.content.match(/(.*) for/)
      title = text.nil? ? "Document" : text[1]
    
      # Now save the attribute
      doc.update_attributes!(:title => title) 
      
      # Result    
      puts "[SUCCESS] Updated title on document: #{doc.id} in #{execution_finished}"
    end
end

def import
    start_time = Time.now
    documents = Document.all
    process_ids = []
    chunk_size = (documents.count / Float($NUM_PROCESSES)).ceil
    
    (0...$NUM_PROCESSES).each do |i|
      start = i * chunk_size
      finish = (i + 1) * chunk_size
      
      chunk = documents.slice(start...finish)
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

import



