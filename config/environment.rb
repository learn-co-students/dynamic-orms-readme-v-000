require 'sqlite3'
require 'pry'
require 'rake'

#DB = {:conn => SQLite3::Database.new("db/songs.db")}
DB = {:conn => SQLite3::Database.new("db/songs.sqlite")}

DB[:conn].execute("DROP TABLE IF EXISTS songs")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true
