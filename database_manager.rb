require 'active_record'


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

    def insert_error(data)
        db_error = DB_Error.new(data)
        db_error.save!
    end

end