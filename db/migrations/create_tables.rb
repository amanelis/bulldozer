require 'rubygems'
require 'json'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'uri'
require 'net/http'
require 'yajl/http_stream'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql", 
  :host     => "localhost", 
  :username => "root", 
  :password => "", 
  :database => "koofers"
)

class CreateTables < ActiveRecord::Migration
  create_table :documents do |t|
    t.integer :university_id
    t.integer :professor_id
  end
  
  create_table :professors do |t|
    t.integer :university_id
    t.string :first_name
    t.string :last_name
    t.integer :rating
    t.string :identifier
  end
  
  create_table :states do |t|
    t.string :abbv
  end
  
  create_table :universities do |t|
    t.string :name
    t.integer :state_id
  end
end