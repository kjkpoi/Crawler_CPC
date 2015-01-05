require 'nokogiri'
require 'net/http'

class HtmlParser

    def initialize(base_url)
        @base_url = base_url
    end

    #TODO: Add Random Header
    def make_page(keyword)
        encoded_keyword = URI::encode(keyword).gsub(/&/, '%26')

        url = @base_url + encoded_keyword
        @referer = url
        puts url
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request.initialize_http_header(make_header)
        response = http.request(request)
        Nokogiri::HTML(response.body)
=begin
        request.each_header { |key, value|
            puts "#{key} : #{value}"
        }

        puts response.code       # => '200'
        puts response.message    # => 'OK'
        puts response.class.name # => 'HTTPOK'
        puts response['header-here']
        puts "Headers: #{response.to_hash.inspect}"
        puts response.body
=end
    end

    def make_header
#        cookie_head1 = (0...rand(30) + 10).map {(65 + rand(2) * 32 + rand(26)).chr}.join
#        cookie_message1 = (0...rand(50) + 10).map {(48 + (rand(2) * (49 + rand(17))) + rand(9)).chr}.join
#        cookie_head2 = (0...rand(40) + 20).map { (48 + rand(79)).chr }.join
#        cookie_message2 = (0...rand(60) + 15).map { (48 + rand(79)).chr }.join

        if rand(2) == 0
            accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        else
            accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        end

        if rand(2) == 0
            user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'
        else
            user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0'
        end

        headers = { 'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
#                    'Accept-Encoding' => 'gzip, deflate',
                    'Accept-Language' => 'ko-kr,ko;q=0.8,en-us;q=0.5,en;q=0.3',
                    'Connection' => 'keep-alive',
                    'Host' => 'www.google.co.kr',
                    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0'}
        headers
    end

end