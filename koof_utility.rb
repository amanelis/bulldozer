require 'rubygems'
require 'thread'
require 'json'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'net/http'
require 'active_record'
require 'rest-client'
require 'rails/all'
require 'socksify'
require 'socksify/http'
require File.expand_path(File.dirname(__FILE__) + '/db/connect')
require File.expand_path(File.dirname(__FILE__) + '/models/document')
require File.expand_path(File.dirname(__FILE__) + '/models/professor')
require File.expand_path(File.dirname(__FILE__) + '/models/state')
require File.expand_path(File.dirname(__FILE__) + '/models/university')



TCPSocket::socks_server = "96.255.108.251"
TCPSocket::socks_port = 1151
begin
  rubyforge_www = TCPSocket.new("rubyforge.org", 80)
rescue Exception => e
  p e.inspect
end



