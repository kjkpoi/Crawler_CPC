require 'active_record'

load 'database_manager.rb'

class DB_Google < ActiveRecord::Base
    self.table_name = 'crawling_google'
end

class DatabaseManagerGoogle < DatabaseManager

    def initialize(url, id, pw, db)
        super(url, id, pw, db)
    end

    def insert_crawling_data(data)
        db_google = DB_Google.new(data)
        db_google.save!
    end

end