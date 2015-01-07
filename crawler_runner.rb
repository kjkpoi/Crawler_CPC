require 'nokogiri'
require 'net/http'
require 'logger'
require 'mysql2'

load 'database_manager.rb'

class CrawlerRunner

    def initialize(company_list_file, keyword_list_file, deny_list_file, db_login_info_file)
        @company_list_file = company_list_file
        @keyword_list_file = keyword_list_file
        @deny_list_file = deny_list_file
        @db_login_info_file = db_login_info_file
    end

    def run
        runner(DateTime.now.strftime('%Y-%m-%d %T'), make_keyword_list(@keyword_list_file, @deny_list_file), 0)
    end

    private
    #Must implement in sub class
    def runner(start_time, keyword_list, index)
        raise Exception
    end

    def save_missingjobs(db_manager, keyword_list, start_time, index)
        i = 0
        data = Hash.new
        data[:start_time] = start_time
        keyword_list.each do |key, value|
            i = i + 1
            data[:keyword] = key
            if i < index
                data[:is_done] = 1
                db_manager.insert_missing_job(data)
            else
                data[:is_done] = 0
                db_manager.insert_missing_job(data)
            end
        end
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

    def make_keyword_list(keyword_list_file, deny_list_file)
        keyword_list = Hash.new
        text = File.open(keyword_list_file).read
        text.gsub!(/\r\n?/, "\n")
        text.each_line do |seed_keyword|
            if keyword_list.exclude? seed_keyword && !is_denied_keyword(seed_keyword, make_deny_list(deny_list_file))
                keyword_list[seed_keyword.gsub(/\s+/, '')] = 1
            end
        end
        keyword_list
    end

    def make_deny_list(deny_list_file)
        File.read(deny_list_file).split
    end

    def make_db_login_info(db_login_info_file)
        login_info = Hash.new
        login_info[:adapter] = 'mysql2'
        login_info[:encoding] = 'utf8'
        File.open(db_login_info_file) do |fp|
            fp.each do |line|
                key, value = line.split("\s")
                login_info[key] = value
            end
        end
        login_info.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end
end