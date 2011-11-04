require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'mechanize'

ua = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 (.NET CLR 3.5.30729) (Prevx 3.0.5)'

# This will return every US state that Koofers follows.
# It will contain a list of every college that is a child 
# of the parent state: AR, AR, CA, CO.....
current_states = Nokogiri::HTML(open('http://koofers.com/'), ua.to_s).css('.footer_column:nth-child(2) a').collect {|x| x.content}

# Here we will loop through each state, jacking all the colleges under it
# From here we will want to process each university and grab all the documnents
# that belong to the university
current_states.each do |state|
  puts "####################   CURRENT STATE: #{state}    ####################"
  state_url       = "http://www.koofers.com/universities?s=#{state}"
  university_urls = Nokogiri::HTML(open(state_url)).css('.univ_list a')
  
  # Now that we have all of the universities of that state
  # loop their them and do some shit
  university_urls.each do |url|
    base_university_url = url['href']
    full_university_url = "http://koofers.com#{base_university_url}"
    path = base_university_url.gsub('/', '')
    mkdir_output = system("mkdir ./documents/#{path}")
        
    # total_pages basically goes on the page that lists all the documents
    # for the given university, looks at the last page of the pagination
    # so it knows how many pages we need to loop through in order to jack
    # all the documents and then when to quit
    total_pages = Nokogiri::HTML(open("#{full_university_url}study-materials?exams")).css('.page_links a:nth-child(5)').collect {|x| x.content}.uniq
    
    # This is where the magic happens :)
    for current_page in (1..total_pages.first.to_i)
      puts "Currently on page: #{current_page} ##########################################"
      base_url = Nokogiri::HTML(open("#{full_university_url}study-materials?exams&p=#{current_page}")).css('.title a')
      base_url.each do |link|
        puts "DOWNLOADING  ##########################################"

        hack_url  = "http://koofers.com#{link['href']}/koofer.pdf&printButton=Yes&sendViewerEvents=Yes"
        puts hack_url
        # hack_cmd  = "wget -r -P ./documents/#{path} #{hack_url}"
        # wget_output = system(hack_cmd)  
        # puts "DOCUMENT: #{path}"
      end
    end    
  end
end