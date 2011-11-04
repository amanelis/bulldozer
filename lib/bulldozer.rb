require 'rubygems'
require 'json'
require 'uri'
require 'open-uri'
require 'net/http'
require 'thread'
require 'nokogiri'
require 'mechanize'
require 'hpricot'
require 'url_utils'

module Bulldozer
  class Client  
    def initialize(*args)
      options = args.extract_options!
    end
    
    def method_missing(sym, *args, &block)
      options = args.extract_options!
      args.nil? ? "" : "" 
    end
  end
  
  autoload :Spider, "bulldozer/spider"
end