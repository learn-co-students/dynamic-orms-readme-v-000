require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")} #creating database
DB[:conn].execute("DROP TABLE IF EXISTS songs") #dropping songs to avoid error
#creating songs table below:
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true
#using #results_as_hash method to return hash and not array
#originally the result is supposed to look like:
#[[1, "Hello", "25"]]
#but now will look like:
#{"id" => 1, "name" => "Hello", "album" => "25", 0 => 1, 1 => "Hello", 2 => "25"}
