require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'active_record'
require 'net/http'
require 'socksify'
require 'socksify/http'

module Scrape
  class UserAgent
    def self.generate_user_agent
      # @agents = Nokogiri::HTML(open('http://www.useragentstring.com/pages/Browserlist/')).css('#liste a').collect { |x| x.content }
      # @ua     = @agents[rand(@agents.length)]
      @ua       = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 (.NET CLR 3.5.30729) (Prevx 3.0.5) '
      @ua
    end
  end

  class Koofers

    def initialize(*args)
      # @date   = Time.now.localtime.strftime("%Y-%m-%d")
      # @agents = Nokogiri::HTML(open('http://www.useragentstring.com/pages/Browserlist/')).css('#liste a').collect { |x| x.content }
      # @ua     = @agents[rand(@agents.length)]
    end

    def interleave_arrays(*args)
      raise 'No arrays to interleave' if args.empty?
      max_length = args.map(&:size).max
      args.map { |e| e.dup.fill(nil, e.size...max_length)}.inject(:zip).flatten.compact
    end

    def import_documents_to_database(*args)

    end

    def import_documents_to_filesysem(*args)
      # Setup user agents and proxies to mask the scrape bot
      date   = Time.now.localtime.strftime("%Y-%m-%d")
      docs   = 0

      # Main page, this is where we will start from. Go here and scrape
      # all the states that koofers has universities too.
      # current_states = Nokogiri::HTML(open('http://www.koofers.com/universities')).css('#public_nav_content a').collect {|x| x.content}
      # states = Nokogiri::HTML(open('http://koofers.com/'), ua.to_s).css('.footer_column:nth-child(2) a').collect { |x| x.content }
      states = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA",
                "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR",
                "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]

      # Loop through all of the states. Iterate through any of the
      # universities in this loop
      states.each do |state|
        puts "####################   CURRENT STATE: #{state}   ####################"

        # Setup any local urls, variables that are scoped towards the
        # current university iteration we are at.
        state_url = "http://www.koofers.com/universities?s=#{state}"
        universities = Nokogiri::HTML(open(state_url), UserAgent.generate_user_agent).css('.univ_list a')

        # Loop through each university in the current state
        universities.each do |university|
          puts "****************   CURRENT UNIVERSITY: #{university.content}"
          base_university_url = university[:href]
          full_university_url = "http://koofers.com#{base_university_url}"
          exam_university_url = "http://koofers.com#{base_university_url}study-materials?exams"
          path = base_university_url.gsub('/', '')
          mkdir_page_results = system("mkdir ./documents/#{path}")

          (1..300).each do |page|
            url = "http://koofers.com#{base_university_url}study-materials?exams&p=#{page}"
            begin
              documents = Nokogiri::HTML(open(url), UserAgent.generate_user_agent).css('.title a')
            rescue Timeout::Error => e
              puts "Error code: #{e.errno}"
              puts "Error message: #{e.error}"
              puts "Looks like this one failed, going to next..."
              next
            end

            if documents.blank? || documents.nil? || documents.empty?
              break
            else
              documents.each do |document|
                puts "DOWNLOADING  ##########################################"

                hack_url  = "http://koofers.com#{document['href']}/koofer.pdf&printButton=Yes&sendViewerEvents=Yes"
                hack_cmd  = "wget -r -P ./exams/#{path} #{hack_url}"
                wget_output = system(hack_cmd)
                # puts "DOCUMENT: #{path}"

                docs = docs + 1
              end
              puts "On page #{page}..."
            end
          end
          puts "Total documents: #{docs}"

        end # universities...
      end # current_states...
      puts "Total Documents for Koofers: #{docs}"
    end

  end # class
end # module

scraper = Scrape::Koofers.new
scraper.import_documents_to_filesysem










