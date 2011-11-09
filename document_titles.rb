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

threads = []

documents = Document.find(:all, :conditions => ["title IS NULL"], :order => 'id ASC')
q = Queue.new
documents.collect { |d| q << d }


puts "Queuing up: #{documents.count} documents"


25.times do
  threads << Thread.new(q) { |q| 
    
      until q.empty?
          doc = q.pop
          begin
            url = doc.url
            page = Nokogiri::HTML(open(url))
          rescue Exception
            puts "[ERROR] Could not open the URL"
            next
          end
  
          page_text = page.css('.content_header_full').first
          next if page.nil?
          text = page_text.content.match(/(.*) for/)
          title = text.nil? ? "Document" : text[1]
  
          # Now save the attribute
          doc.update_attributes!(:title => title) 

          puts "[SUCCESS] Updated title on document: #{doc.id} with title: #{doc.title}"
      end #until empty
  }
  
end


# Join these hoes
threads.each { |t|  t.join }

puts "[FINISHED] Process completed. --------------------------------------------------"



