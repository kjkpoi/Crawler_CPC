require 'nokogiri'
require 'net/http'
require 'open-uri'

class HtmlParser

    def initialize(base_url, company_list)
        @base_url = base_url
        @company_list = company_list
        @deny_list = get_deny_list('./Resource/deny_list.txt')
    end

    #TODO: Add Random Header
    def make_page_net_version(keyword, previous_keyword)
        encoded_keyword = URI::encode(keyword).gsub(/&/, '%26')

        if rand(2) == 0
            accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        else
            accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        end

        if rand(3) == 0 or previous_keyword == nil
            referer = 'search.naver.com'
        else
            referer = @base_url + previous_keyword
        end

        if rand(2) == 0
            user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'
        else
            user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0'
        end


        url = @base_url + encoded_keyword
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        headers = { 'Accept' => accept,
                    'Accept-Language' => 'ko-kr,ko;q=0.8,en-us;q=0.5,en;q=0.3',
                    'Connection' => 'keep-alive',
                    'Referer' => referer,
                    'Host' => 'www.naver.com',
                    'User-Agent' => user_agent,
                    'Cache-Control' => 'no-cache'}
        request.initialize_http_header(headers)
        response = http.request(request)

        if response.code.include? '403'
            raise Exception
        end

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
        page = Nokogiri::HTML(response.body)
        page
    end

    #TODO: Random Header Maker Fix
    def make_page(keyword, previous_keyword)
        encoded_keyword = URI::encode(keyword).gsub(/&/, '%26')
        cookie_head1 = (0...rand(30) + 10).map {(65 + rand(2) * 32 + rand(26)).chr}.join
        cookie_message1 = (0...rand(50) + 10).map {(48 + (rand(2) * (49 + rand(17))) + rand(9)).chr}.join

        cookie_head2 = (0...rand(40) + 20).map { (48 + rand(79)).chr }.join
        cookie_message2 = (0...rand(60) + 15).map { (48 + rand(79)).chr }.join


        if rand(2) == 0
            accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        else
            accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        end
        accept_language = "ko-kr,ko;q=0.8,en-us;q=0.'#{rand(1) + 5}',en;q=0.'#{rand(1) + 3}'"

        if rand(3) == 0 or previous_keyword == nil
            referer = 'http://www.naver.com/'
        else
            referer = @base_url + previous_keyword
        end

        if rand(2) == 0
            user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0'
        else
            user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0'
        end
        page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                                   'Accept' => accept,
                                   cookie_head1 => cookie_message1,
                                   cookie_head2 => cookie_message2,
                                   'Accept-Language' => accept_language,
                                   'Connection' => 'keep-alive',
                                   'Host' => 'search.naver.com',
                                   'Referer' => referer,
                                   'User-Agent' => user_agent))
=begin
        page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                               cookie_head1 => cookie_message1,
                               cookie_head2 => cookie_message2,
                               'Accept-Language' => accept_language,
                               'User-Agent' => user_agent,
                               :proxy => URI.parse('http://111.1.36.26:80')))
=end

=begin
        case cookie_type % 5
            when 0
                page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                                           cookie_head1 => cookie_message1,
                                           cookie_head2 => cookie_message2,
                                           'Accept-Language' => accept_language,
                                           'User-Agent' => user_agent))
            when 1
                page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                                           'Accept' => accept,
                                           'Referer' => referer,
                                           'asdf' => 'wer',
                                           cookie_head2 => cookie_message2))
            when 2
                page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                                           'Connection' => 'keep-alive',
                                           cookie_head2 => cookie_message1,
                                           'Host' => 'search.naver.com'))
            when 3
                page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                                           'Accept' => accept,
                                           'Accept-Language' => accept_language,
                                           'Connection' => 'keep-alive',
                                           'Referer' => referer,
                                           cookie_head1 => cookie_message2,
                                           'User-Agent' => user_agent))
            when 4
                page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                                           cookie_head2 => cookie_message2,
                                           'Referer' => referer))
        end
=end
=begin
        page = Nokogiri::HTML(open(@base_url + encoded_keyword,
                                   'Accept' => accept,
                                   'Accept-Language' => accept_language,
                                   'Connection' => 'keep-alive',
                                   'Host' => 'search.naver.com',
                                   'Referer' => referer,
                                   'User-Agent' => user_agent))

        page = Nokogiri::HTML(open(@base_url + URI::encode(keyword),
                                   'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                                   'Accept-Language' => 'ko-kr,ko;q=0.8,en-us;q=0.5,en;q=0.3',
                                   'Connection' => 'keep-alive',
                                   'Host' => 'search.naver.com',
                                   'Referer' => 'http://www.naver.com/',
                                   'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0'))
=end
        page
    end

    def is_denied_keyword(keyword)
        flag = false
        @deny_list.each { |deny_keyword|
            if keyword.strip.include? deny_keyword
                flag = true
                break
            end
        }
        flag
    end

    def get_related_keywords(page)
        result = Array.new
        page.css('dd.lst_relate li').each do |keyword|
            flag = true
            @deny_list.each { |deny_keyword|
                if keyword.text.strip.include? deny_keyword
                    flag = false
                    break
                end
            }

            if flag
                result.push(keyword.text.strip)
            end

        end
        result
    end

    def get_adlink_info(page)
        if @company_list.size <= 0
            puts 'company list error'
            return
        end

        result = Hash.new
        result['powerlink'] = [0, 0, 0, 0]
        result['bizsite'] = [0, 0, 0, 0]
        page.css('div.ad_section').each do |section|
            if section.text.include? '파워링크'
                result['powerlink'] = get_company_info(section.text)
            elsif section.text.include? '비즈사이트'
                result['bizsite'] = get_company_info(section.text)
            end
        end
        result
    end


    private
    def get_company_info(text)
        result = Array.new
        @company_list.each do |company|
            if text.include? company
                result.push(1)
            else
                result.push(0)
            end
        end
        result
    end

    #TODO: make deny_list  sets
    def get_deny_list(src)
        deny_list = Array.new
        text = File.open(src).read
        text.gsub!(/\r\n?/, "\n")
        text.each_line do |deny_keyword|
            deny_list.push(deny_keyword.gsub(/\s+/, ''))
        end
        deny_list
    end

end