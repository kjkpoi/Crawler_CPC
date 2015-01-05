require 'nokogiri'
require 'net/http'

load 'html_parser.rb'

class HtmlParserGoogle < HtmlParser

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

    def get_adlink_info(page, company_list)
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
end