require 'active_record'
require 'mysql2'

class DB_Error < ActiveRecord::Base
    self.table_name = 'crawling_error'
end

class DB_missing_job < ActiveRecord::Base
    self.table_name = 'crawling_missing_job'
end

class DB_Google < ActiveRecord::Base
    self.table_name = 'crawling_google'
end

class DB_Google_Keyword < ActiveRecord::Base
    self.table_name = 'crawling_google_keyword_only'
end

class DB_Naver < ActiveRecord::Base
    self.table_name = 'crawling_naver'
end

class DatabaseManager

    def initialize(db_login_info)
        ActiveRecord::Base.establish_connection(db_login_info)
    end

    def insert_crawling_data_naver(data)
        db_naver = DB_Naver.new(data)
        db_naver.save!
    end

    def insert_crawling_data_google(data)
        db_google = DB_Google.new(data)
        db_google.save!
    end

    def insert_crawling_data_google_keyword(data)
        db_google = DB_Google_Keyword.new(data)
        db_google.save!
    end


    def insert_error(data)
        db_error = DB_Error.new(data)
        db_error.save!
    end

    def insert_missing_job(data)
        db_missing_job = DB_missing_job.new(data)
        db_missing_job.save!
    end

    def restore_missing_jobs(start_time)
        index = 0
        keyword_list = Hash.new
        DB_missing_job.where(:start_time => start_time).select('keyword, is_done') do |job|
            puts job[:keyword].encoding
            keyword_list[job.keyword] = 1
            if job[:is_done] == 1
                index = index + 1
            end
        end
        return keyword_list, index
    end
end