require 'active_record'

class DB_Error < ActiveRecord::Base
    self.table_name = 'crawling_error'
end

class DB_missing_job < ActiveRecord::Base
    self.table_name = 'crawling_missing_job'
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

    def insert_error(data)
        db_error = DB_Error.new(data)
        db_error.save!
    end

    def insert_missing_job(data)
        db_missing_job = DB_missing_job.new(data)
        db_missing_job.save!
    end
end