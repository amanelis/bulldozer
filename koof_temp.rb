require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'active_record'

module Scrape
  class Koofers
    # Setup globals
    attr_accessor :date, :ua
    
    def initialize(*args)
      @date   = Time.now.localtime.strftime("%Y-%m-%d")
      @agents = Nokogiri::HTML(open('http://www.useragentstring.com/pages/Browserlist/')).css('#liste a').collect { |x| x.content }
      @ua     = @agents[rand(@agents.length)] 
    end
    
    def interleave_arrays(*args)
      raise 'No arrays to interleave' if args.empty?
      max_length = args.map(&:size).max
      args.map { |e| e.dup.fill(nil, e.size...max_length)}.inject(:zip).flatten.compact
    end

    
  end # class
end # module

url = "http://www.koofers.com/university-of-texas-austin-utexas/study-materials?exams&p=2"
doc = Nokogiri::HTML(open(url)).css('.title a').collect { |obj| obj[:href] }

puts doc
