require 'active_record'

load 'database_manager.rb'

class DB_Google_Keyword < ActiveRecord::Base
    self.table_name = 'crawling_google_keyword_only'
end

class DatabaseManagerGoogleKeyword < DatabaseManager

    def initialize(url, id, pw, db)
        super(url, id, pw, db)
    end

    def insert_crawling_data(data)
        db_google = DB_Google_Keyword.new(data)
        db_google.save!
    end

end