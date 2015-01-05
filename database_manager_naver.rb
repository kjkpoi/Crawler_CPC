require 'active_record'

load 'database_manager.rb'

class DB_Naver < ActiveRecord::Base
    self.table_name = 'crawling_naver'
end

class DatabaseManagerNaver < DatabaseManager

    def initialize(url, id, pw, db)
        super(url, id, pw, db)
    end

    def insert_crawling_data(data)
        db_naver = DB_Naver.new(data)
        db_naver.save!
    end

end