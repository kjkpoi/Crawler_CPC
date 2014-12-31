require 'mysql2'

class DatabaseManager

    def initialize(url, id, pw, db)
        @client = Mysql2::Client.new(:host => url, :username => id, :password => pw, :database => db)
    end

    def push_crawling_info(start_date, keyword, ad_info)
        @client.query("INSERT INTO crawling_naver(start_time, keyword, powerlink_jobplanet, powerlink_jobkorea,
                        powerlink_saramin, powerlink_incruit, bizsite_jobplanet, bizsite_jobkorea, bizsite_saramin, bizsite_incruit)
                        Values ('#{start_date}', '#{keyword}', '#{ad_info['powerlink'][0]}', '#{ad_info['powerlink'][1]}', '#{ad_info['powerlink'][2]}', '#{ad_info['powerlink'][3]}',
                        '#{ad_info['bizsite'][0]}', '#{ad_info['bizsite'][1]}', '#{ad_info['bizsite'][2]}', '#{ad_info['bizsite'][3]}')")
    end

    def push_error(start_date, keyword, error_message)
        @client.query("INSERT INTO error_naver(start_time, keyword, error_msg)
                        Values ('#{start_date}', '#{keyword}', '#{error_message}')")
    end

end