require 'nokogiri'
require 'net/http'

load 'crawler_runner.rb'
load 'html_parser_naver.rb'
load 'database_manager_naver.rb'

class CrawlerRunnerNaver < CrawlerRunner

    def initialize(company_list_file, keyword_list_file, deny_list_file, login_info_file)
        super(company_list_file, keyword_list_file, deny_list_file)
        @login_info = make_login_info(login_info_file)
    end

    def run
        runner(make_parser('http://search.naver.com/search.naver?fbm=0&sm=tab_hty.top&where=nexearch&ie=utf8&query='),
               make_db_manager)
    end

    private
    def make_parser(url)
        HtmlParserNaver.new(url)
    end

    def make_db_manager
        DatabaseManagerNaver.new(@login_info[:url], @login_info[:id], @login_info[:pw], @login_info[:db])
    end
end