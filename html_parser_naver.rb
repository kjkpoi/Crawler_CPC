require 'nokogiri'
require 'net/http'

load 'html_parser.rb'

class HtmlParserNaver < HtmlParser

    def initialize(base_url)
        super(base_url)
    end

    def get_related_keywords(page, deny_list)
        result = Array.new
        page.css('dd.lst_relate li').each do |keyword|
            flag = true
            deny_list.each { |deny_keyword|
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

    def get_adlink_info(page, company_list)
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
end