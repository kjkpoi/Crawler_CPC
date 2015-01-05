require 'mysql2'
require 'active_record'

class DB_Naver < ActiveRecord::Base
    self.table_name = 'crawling_naver'
end

class DB_Google < ActiveRecord::Base
    self.table_name = 'crawling_google'
end

class DB_Error < ActiveRecord::Base
    self.table_name = 'error_naver'
end


class DatabaseManager

    def initialize(url, id, pw, db)
        ActiveRecord::Base.establish_connection(:adapter => :mysql,
                                                :database => db,
                                                :username => id,
                                                :password => pw,
                                                :host => url,
                                                :encoding => 'utf8')
    end

    def insert_naver_crawling_info(data)
        db_naver = DB_Naver.new(data)
        db_naver.save!
    end

    def insert_google_crawling_info(data)
        db_google = DB_Google.new(data)
        db_google.save!
    end

    def insert_error(data)
        db_error = DB_Error.new(data)
        db_error.save!
    end

end