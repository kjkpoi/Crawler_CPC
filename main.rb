load 'crawler_runner_google.rb'
load 'crawler_runner_naver.rb'
load 'crawler_runner_google_keyword.rb'


=begin
crawler_runner_google_keyword = CrawlerRunnerGoogleKeyword.new('./Resource/company_list.txt',
                                                './Resource/test_seed_keyword_list.txt',
                                                './Resource/deny_list.txt',
                                                './Resource/database_login_info.txt')

crawler_runner_google_keyword.run
=end


crawler_runner_google = CrawlerRunnerGoogle.new('./Resource/company_list.txt',
                                                './Resource/test_seed_keyword_list.txt',
                                                './Resource/deny_list.txt',
                                                './Resource/database_login_info.txt')

crawler_runner_google.run


=begin
crawler_runner_naver = CrawlerRunnerNaver.new('./Resource/company_list.txt',
                                                './Resource/seed_keyword_list.txt',
                                                './Resource/deny_list.txt',
                                                './Resource/database_login_info.txt')

crawler_runner_naver.run
=end