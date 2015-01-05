load 'crawler_runner_google.rb'
load 'crawler_runner_naver.rb'


crawler_runner_google = CrawlerRunnerGoogle.new('./Resource/company_list.txt',
                                                './Resource/seed_keyword_list.txt',
                                                './Resource/deny_list.txt',
                                                './Resource/database_login_info.txt')

crawler_runner_google.run


=begin

 -- Run Naver Crawler --

crawler_runner_naver = CrawlerRunnerGoogle.new('./Resource/company_list.txt',
                                                './Resource/seed_keyword_list.txt',
                                                './Resource/deny_list.txt',
                                                './Resource/database_login_info.txt')

crawler_runner_naver.run
=end