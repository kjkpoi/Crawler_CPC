require 'nokogiri'
require 'net/http'
require 'logger'

class CrawlerRunner


    def initialize(company_list_file, keyword_list_file, deny_list_file)
        @company_list = make_company_list(company_list_file)
        @keyword_list = make_keyword_list(keyword_list_file)
        @deny_list = make_deny_list(deny_list_file)
    end

    private
    def runner(parser, db_manager)
        start_time = DateTime.now.strftime('%Y-%m-%d %T')
        error_info = Hash.new
        count_db = 0
        index = 0
        logger = make_logger
        logger.info('start')
        while @keyword_list.length > index do
            begin
                current_keyword = @keyword_list.keys[index]
                relate_value = @keyword_list.values[index]

                logger.info("------------- Start '#{current_keyword}' ---------------")
                logger.info("Hash Size -> '#{@keyword_list.length}'")
                current_page = parser.make_page(current_keyword)
                ad_info =  parser.get_adlink_info(current_page, @company_list)

                isValuable = ad_info.values.include? 1

                ad_info[:crawling_time] = DateTime.now.strftime('%Y-%m-%d %T')
                ad_info[:start_time] = start_time
                ad_info[:keyword] = current_keyword

                parser.get_related_keywords(current_page, @deny_list)
                if isValuable
                    unless is_denied_keyword(current_keyword, @deny_list)
                        db_manager.insert_crawling_data(ad_info)
                        logger.info("Insert DB '#{current_keyword}'")
                        count_db = count_db + 1
                    end

                    parser.get_related_keywords(current_page, @deny_list).each do |keyword|
                        unless @keyword_list.has_key? keyword
                            @keyword_list[keyword] = 1
                        end
                    end
                elsif relate_value > 0
                    parser.get_related_keywords(current_page, @deny_list).each do |keyword|
                        unless @keyword_list.has_key? keyword
                            @keyword_list[keyword] = relate_value - 1
                        end
                    end
                end

                index = index + 1

                sleep(5 + rand(8))

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

    def make_logger
        logger = Logger.new('logfile.log', 'daily')
        logger.level = Logger::INFO
        logger
    end

    def is_denied_keyword(keyword, deny_list)
        flag = false
        deny_list.each { |deny_keyword|
            if keyword.strip.include? deny_keyword
                flag = true
                break
            end
        }
        flag
    end


    def make_company_list(company_list_file)
        File.read(company_list_file).split
    end

    def make_keyword_list(keyword_list_file)
        keyword_list = Hash.new
        text = File.open(keyword_list_file).read
        text.gsub!(/\r\n?/, "\n")
        text.each_line do |seed_keyword|
            unless keyword_list.include? seed_keyword
                keyword_list[seed_keyword.gsub(/\s+/, '')] = 1
            end
        end
        keyword_list
    end

    def make_deny_list(deny_list_file)
        File.read(deny_list_file).split
    end

    def make_login_info(login_info_file)
        login_info = Hash.new
        File.open(login_info_file) do |fp|
            fp.each do |line|
                key, value = line.split("\s")
                login_info[key] = value
            end
        end
        login_info.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

    def make_db_manager(login_info)
        DatabaseManager.new(login_info[:url], login_info[:id], login_info[:pw], login_info[:db])
    end
end