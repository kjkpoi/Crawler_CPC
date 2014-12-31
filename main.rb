require 'rubygems'
require 'logger'


load 'HtmlParser.rb'
load 'DatabaseManager.rb'

#TODO: Temporary main

logger = Logger.new('logfile.log')
logger.level = Logger::INFO

start_date = DateTime.now.strftime('%Y-%m-%d %T')

keyword_list = Hash.new

text = File.open('./Resource/seed_list.txt').read
text.gsub!(/\r\n?/, "\n")
text.each_line do |seed_keyword|
    unless keyword_list.include? seed_keyword
        keyword_list[seed_keyword.gsub(/\s+/, '')] = 1
    end
end

company_list = File.read('./Resource/company_list.txt').split
parser = HtmlParser.new('http://search.naver.com/search.naver?fbm=0&sm=tab_hty.top&where=nexearch&ie=utf8&query=', company_list)
db_manager = DatabaseManager.new('localhost', 'crawler', 'jobplanet', 'AD_Crawler')

index = 0
count_db = 0
puts 'Naver CPC Crwaling Start'
previous_keyword = nil

while keyword_list.length > index do
    begin
        current_keyword = keyword_list.keys[index]
        relate_value = keyword_list.values[index]

        logger.info("------------- Start '#{current_keyword}' ---------------")
        logger.info("Hash Size -> '#{keyword_list.length}'")
        current_page = parser.make_page_net_version(current_keyword, previous_keyword)
#        current_page = parser.make_page(current_keyword, previous_keyword)
        ad_info =  parser.get_adlink_info(current_page)
        if ad_info['powerlink'].include? 1 or ad_info['bizsite'].include? 1
            unless parser.is_denied_keyword(current_keyword)
                db_manager.push_crawling_info(start_date, current_keyword, ad_info)
                logger.info("Insert DB '#{current_keyword}'")
                count_db = count_db + 1
            end

            parser.get_related_keywords(current_page).each do |keyword|
                unless keyword_list.has_key? keyword
                    keyword_list[keyword.gsub(/\s+/, '')] = 1
                end
            end
        elsif relate_value > 0
            parser.get_related_keywords(current_page).each do |keyword|
                unless keyword_list.has_key? keyword
                    keyword_list[keyword.gsub(/\s+/, '')] = relate_value - 1
                end
            end
        end

        previous_keyword = current_keyword
        index = index + 1

        sleep(5 + rand(8))
=begin
        if index % 100 == 0
            puts "#{DateTime.now.strftime('%Y-%m-%d %T')}: Index -> #{index}, Hash_Size -> #{keyword_list.length}, Count_DB -> #{count_db}"
            logger.info("Job Done, Index -> '#{index}'")
        end

        if index % 10000 == 0
            logger.info("SLEEPING 5 minutes, Index -> '#{index}'")
            sleep(300)
        end
=end
    rescue SystemExit, Interrupt
        logger.warn('Crawler SystemExit, Interrupt')
        raise
    rescue Exception => e
        logger.error("Crawler Exception #{e}, #{e.backtrace}")
        puts "#{e}, #{e.backtrace}"
        if e.to_s.include? '403'
            logger.error("403 HTTP Request, Stop Crawling, #{e}, #{e.backtrace}")
        end
        sleep(600)
        break
        #parser = HtmlParser.new('http://search.naver.com/search.naver?sm=tab_hty.top&where=nexearch&ie=utf8&query=', company_list)
        #db_manager = DatabaseManager.new('localhost', 'crawler', 'jobplanet', 'AD_Crawler')
        #db_manager.push_error(start_date, current_keyword, e)
    end
end