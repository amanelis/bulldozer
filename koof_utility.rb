require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'active_record'

one_school = "http://www.koofers.com/university-of-alaska-anchorage-uaa-alaska/study-materials?exams"
two_school = "http://www.koofers.com/central-washington-university-cwu/study-materials?exams"
thr_school = "http://www.koofers.com/university-of-texas-san-antonio-utsa/study-materials?exams"
for_school = "http://www.koofers.com/jacksonville-state-university-jsu/study-materials?exams"

schools    = [one_school, two_school, thr_school, for_school]
css_paths  = ['.position', '#public_browse_content a:nth-child(3)', '#public_browse_content a:nth-child(4)', '#public_browse_content a:nth-child(5)']


# Iterate throught the schools, return their number of pages to paginate through
schools.each do |school|
  puts "------------------ #{school}"
  
  # Here we need to determine wheter or not to setup pagination
  css_paths  = ['.position', '#public_browse_content a:nth-child(3)', '#public_browse_content a:nth-child(4)', '#public_browse_content a:nth-child(5)']
  page_results = css_paths.inject([]) { |data, css| data << Nokogiri::HTML(open(exam_university_url)).css(css).collect { |element| element.content }.uniq }

  if page_results[1].empty? && page_results[2].empty? && page_results[3].empty?
    pages = 0
    p "Block 0"
  elsif page_results[3].include?("Next") || page_results[3].to_s.downcase.include?("next")
    pages = page_results[2]
    p "Block 1"
  elsif page_results[2].empty? && page_results[3].present?
    pages = page_results[3]
    p "Block 2"
  elsif page_results[3].empty? && (page_results[2].include?("Next") || page_results[2].to_s.downcase.include?("next"))
    pages = page_results[1]
    p "Block 3"
  elsif page_results.nil?
    pages = 0
    b "Block 4"
  elsif page_results[2].include?("Next") || page_results[2].to_s.downcase.include?("next")
    pages = page_results[1]
    p "Block 5"
  end

  # This is where the magic happens to gather the documents
  puts "Current pages: #{pages}"
  puts pages.class

end




