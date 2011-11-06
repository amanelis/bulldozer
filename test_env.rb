require 'rubygems'
require 'thread'
require 'json'
require 'uri'
require 'open-uri'
require 'aws/s3'
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
require File.expand_path(File.dirname(__FILE__) + '/models/result')
require File.expand_path(File.dirname(__FILE__) + '/models/university')
require File.expand_path(File.dirname(__FILE__) + '/include/amazon')

# Connect to Amazon S3
a = AmazonS3Asset.new

puts "Checking university object..."
universities = University.all
puts "Universities: #{universities.count}"

puts ''
puts ''

puts "Checking document object..."
documents = Document.all
puts "Documents: #{documents.count}"

# puts "Emptying the S3 bucket..."
# r = a.empty_bucket("frtb-documents")




