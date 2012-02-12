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

# Store our threads
threads = []

# Queue to store the docs
q = Queue.new

# Keep track of success failure
errors  = 0
success = 0

# Grab the documents based on no title
documents = Document.find(:all, :conditions => ["title IS NULL"], :order => 'id ASC')
documents.collect { |d| q << d }

# Number of threads
25.times do
  threads << Thread.new(q) { |q| 
        
      until q.empty?
          doc = q.pop
          begin
            url = doc.url
            page = Nokogiri::HTML(open(url))
          rescue Exception
            puts "[ERROR] Could not open the URL"
            errors += 1
            next
          end
          
          begin 
            # Grab the css element
            page_title        = page.css('.content_header_full').first
            page_category     = page.css('tr:nth-child(4) a').first
            page_date         = page.css('tr:nth-child(6) td:nth-child(2)').first
            page_description  = page.css('.koofer_sample_text').first
            
            
            
            title         = page_text.content
            category      = page_category.content
            date          = page_data.content
            description   = page_description.content
          rescue NoMethodError
            puts "[ERROR] NoMethodError for page_text.content on doc: #{doc.id} for #{url}"
            errors += 1
            next
          end
  
          # Now save the attribute
          doc.update_attributes!(:title => title, :category => page_category, :term => date, :description => description) 

          puts "[SUCCESS] Updated title on document: #{doc.id} with title: #{doc.title}"
      end #until empty
  }
end


# Join these hoes
threads.each { |t|  t.join }

puts "[FINISHED] Process completed. --------------------------------------------------"



