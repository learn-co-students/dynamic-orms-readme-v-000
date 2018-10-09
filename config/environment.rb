require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")} # create the database
DB[:conn].execute("DROP TABLE IF EXISTS songs") # drop songs to avoid an error

# create the songs table
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
# when a SELECT statement is executed,
# return it as a hash with column names as keys
# instead of as an array
DB[:conn].results_as_hash = true
