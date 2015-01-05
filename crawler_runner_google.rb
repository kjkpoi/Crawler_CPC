require 'nokogiri'
require 'net/http'

load 'crawler_runner.rb'
load 'html_parser_google.rb'
load 'database_manager_google.rb'

class CrawlerRunnerGoogle < CrawlerRunner

    def initialize(company_list_file, keyword_list_file, deny_list_file, login_info_file)
        super(company_list_file, keyword_list_file, deny_list_file)
        @login_info = make_login_info(login_info_file)
    end

    def run
        runner(make_parser('https://www.google.co.kr/search?q='),
               make_db_manager)
    end

    private
    def make_parser(url)
        HtmlParserGoogle.new(url)
    end

    def make_db_manager
        DatabaseManagerGoogle.new(@login_info[:url], @login_info[:id], @login_info[:pw], @login_info[:db])
    end
end