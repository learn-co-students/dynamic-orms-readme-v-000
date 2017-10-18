require 'sqlite3'

#create out database
DB = {:conn => SQLite3::Database.new("db/songs.db")}
#dropping table to avoid an error
DB[:conn].execute("DROP TABLE IF EXISTS songs")

#create our songs table
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

#execute code via sqlite #execute
DB[:conn].execute(sql)

#have databate resuults returned as hashes.  This method says: when a SELECT statement is executed, don't return a
#database row as an array, return it as a hash with the column names as keys.
DB[:conn].results_as_hash = true
