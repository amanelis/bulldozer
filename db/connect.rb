require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql", 
  :host     => "localhost", 
  :username => "root", 
  :password => "", 
  :database => "koofers",
  :pool     => 25
  :database => "zulu"
)