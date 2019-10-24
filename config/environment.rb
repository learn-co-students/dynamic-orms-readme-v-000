require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")} # Here we are creating the DB
DB[:conn].execute("DROP TABLE IF EXISTS songs") # Drop songs to avoid an error

sql = <<-SQL /*Here we are creating the songs table*/
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true # here we use the #results_as_hash method that says: when a SELECT statement is executed, don't return a database row as an array, return it as a hash with the column names as keys.
