require 'nokogiri'
require 'net/http'

class HtmlParser

    def initialize(base_url)
        @base_url = base_url
    end

    #TODO: Add Random Header
    def make_page(keyword, use_ssl, request_header)
        encoded_keyword = URI::encode(keyword).gsub(/&/, '%26')

        url = @base_url + encoded_keyword
        @referer = url
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)

        if use_ssl
            http.use_ssl = true
        end

        request = Net::HTTP::Get.new(uri.request_uri)
        request.initialize_http_header(request_header)
        response = http.request(request)
        Nokogiri::HTML(response.body)
    end

    def get_related_keywords(page, deny_list, selector)
        result = Array.new
        page.css(selector).each do |keyword|
            flag = true
            deny_list.each { |deny_keyword|
                if keyword.text.strip.include? deny_keyword
                    flag = false
                    break
                end
            }

            if flag
                result.push(keyword.text.strip.gsub(/\s+/, ''))
            end
        end

        result
    end

    def get_adlink_info_naver(page, company_list)
        if company_list.size <= 0
            puts 'company list error'
            return
        end

        result = Hash.new
        page.css('div.ad_section').each do |section|
            caption_text = '??'
            if section.text.include? '파워링크'
                caption_text = 'powerlink'
            elsif section.text.include? '비즈사이트'
                caption_text = 'bizsite'
            end

            company_list.each do |company|
                result["#{caption_text}_#{company}"] = 0
                if section.text.include? company
                    result["#{caption_text}_#{company}"] = 1
                end
            end
        end

        result
    end

    def get_adlink_info_google(page, company_list)
        if company_list.size <= 0
            puts 'company list error'
            return
        end
        result = Hash.new

        company_list.each do |company|
            result[company] = 0
        end

        page.css('li.ads-ad').each do |section|
            company_list.each do |company|
                if section.text.include? company
                    result[company] = 1
                end
            end
        end

        result
    end

    def get_adlink_info_google_keyword(page)
        result = ''
        page.css('li.ads-ad cite').each do |section|
            result = result + section.text + '; '
        end

        result
    end


end