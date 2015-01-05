require 'nokogiri'
require 'net/http'

load 'crawler_runner.rb'
load 'html_parser_google_keyword.rb'
load 'database_manager_google_keyword.rb'

class CrawlerRunnerGoogleKeyword < CrawlerRunner

    def initialize(company_list_file, keyword_list_file, deny_list_file, login_info_file)
        super(company_list_file, keyword_list_file, deny_list_file)
        @login_info = make_login_info(login_info_file)
    end

    def run
        parser = make_parser('https://www.google.co.kr/search?q=')
        db_manager = make_db_manager
        start_time = DateTime.now.strftime('%Y-%m-%d %T')
        error_info = Hash.new
        count_db = 0
        index = 0
        logger = make_logger
        logger.info('google keyword runner start')
        while @keyword_list.length > index do
            begin
                current_keyword = @keyword_list.keys[index]
                relate_value = @keyword_list.values[index]

                puts current_keyword
                logger.info("------------- Start '#{current_keyword}' ---------------")
                logger.info("Hash Size -> '#{@keyword_list.length}'")
                current_page = parser.make_page(current_keyword)
                ad_info = Hash.new
                ad_info[:company] = parser.get_adlink_info(current_page)

                ad_info[:crawling_time] = DateTime.now.strftime('%Y-%m-%d %T')
                ad_info[:start_time] = start_time
                ad_info[:keyword] = current_keyword

                puts ad_info
                parser.get_related_keywords(current_page, @deny_list)
                unless is_denied_keyword(current_keyword, @deny_list)
                    db_manager.insert_crawling_data(ad_info)
                    logger.info("Insert DB '#{current_keyword}'")
                    count_db = count_db + 1
                end

                index = index + 1
                sleep_policy(index)
            rescue SystemExit, Interrupt
                logger.warn('Crawler SystemExit, Interrupt')
                raise
            rescue Exception => e
                logger.error("Crawler Exception #{e}, #{e.backtrace}")
                puts "#{e}, #{e.backtrace}"
                if e.to_s.include? '403'
                    logger.error("403 HTTP Request, Stop Crawling, #{e}, #{e.backtrace}")
                end

                error_info[:start_time] = start_time
                error_info[:error_time] = DateTime.now.strftime('%Y-%m-%d %T')
                error_info[:keyword] = current_keyword
                error_info[:error_msg] = "#{e}, #{e.backtrace}"
                db_manager.insert_error(error_info)
                break
            end
        end
    end

    private
    def make_parser(url)
        HtmlParserGoogleKeyword.new(url)
    end

    def make_db_manager
        DatabaseManagerGoogleKeyword.new(@login_info[:url], @login_info[:id], @login_info[:pw], @login_info[:db])
    end
end