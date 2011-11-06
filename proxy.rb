require 'rubygems'
require 'thread'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'aws/s3'
require 'rails/all'
require 'active_record' 
require 'net/http'

# Proxy ip addresses
$PROXIES = [{:ip => '128.143.6.130', :port => 3128}]

# User agents list
$AGENTS  = ['Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.6 (KHTML, like Gecko) Chrome/16.0.897.0 Safari/535.6',
           'Mozilla/5.0 (X11; U; Linux i686; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.84 Safari/534.13',
           'Mozilla/5.0 (X11; U; CrOS i686 0.9.128; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.341 Safari/534.10',
           'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 1.0.3705; .NET CLR 1.1.4322)',
           'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; Media Center PC 6.0; InfoPath.2; MS-RTC LM 8)',
           'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6',
           'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)',
           'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)',
           'Googlebot/2.1 ( http://www.googlebot.com/bot.html)',
           'Mozilla/2.0 (compatible; Ask Jeeves)',
           'Msnbot-Products/1.0 (+http://search.msn.com/msnbot.htm)']

url = "http://s3.amazonaws.com/frtbcdn/document-31-2009-09-05.pdf"

proxy_addr = '129.115.248.200'
proxy_port = 80

# puts "Attempting to connect to proxy..."        
# Net::HTTP::Proxy(proxy_addr, proxy_port).start('www.freetestbank.com') { |http|
#   p http.inspect
# }

proxy         = Net::HTTP::Proxy(proxy_addr, proxy_port)  
url           = URI.parse('http://www.koofers.com/university-of-texas-san-antonio-utsa/')  
http_response = proxy.get_response(url)  
document      = Nokogiri::HTML(http_response.body)

puts document.inspect