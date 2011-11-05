require 'rubygems'
require 'json'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'uri'
require 'net/http'
require 'yajl/http_stream'
require 'active_record'

connection = ActiveRecord::Base.establish_connection(
  :adapter  => "mysql", 
  :host     => "localhost", 
  :username => "root", 
  :password => "", 
  :database => "koofers"
)

ActiveRecord::Base.connection.create_database(:koofers) unless connection

unless ActiveRecord::Base.connection.table_exists?(:documents)
  class CreateTables < ActiveRecord::Migration
    transaction do
      create_table :documents do |t|
        t.integer :university_id
        t.integer :professor_id
        t.string :course_name
        t.string :url
        t.string :path
        t.string :type
      end
  
      create_table :professors do |t|
        t.integer :university_id
        t.string :first_name
        t.string :last_name
        t.float :rating
        t.integer :identifier
        t.string :department_name
        t.string :url
      end
  
      create_table :states do |t|
        t.string :abbv
      end
  
      create_table :universities do |t|
        t.string :name
        t.string :slug
        t.integer :state_id
        t.string :url
      end
    end
  end
end

states  = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA",
           "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR",
           "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]

class State < ActiveRecord::Base; end
states.collect { |state| State.create!(:abbv => state) }
