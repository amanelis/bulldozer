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
      @already_visited = {}
    end
  end
  
  autoload :Spider, "bulldozer/spider"
end