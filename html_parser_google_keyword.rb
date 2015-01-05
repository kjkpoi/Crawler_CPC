require 'nokogiri'
require 'net/http'

load 'html_parser.rb'

class HtmlParserGoogleKeyword < HtmlParser

    def initialize(base_url)
        super(base_url)
    end

    def get_related_keywords(page, deny_list)
        result = Array.new
        page.css('p._e4b').each do |keyword|
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

    def get_adlink_info(page)

        result = ''
        page.css('li.ads-ad cite').each do |section|
            puts section.text
            result = result + section.text + '; '
        end

        result
    end
end