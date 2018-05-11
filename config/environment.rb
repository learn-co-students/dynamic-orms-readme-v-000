require 'sqlite3'

#create SQL database
DB = {:conn => SQLite3::Database.new("db/songs.db")}

#clear any songs table from that database before starting
DB[:conn].execute("DROP TABLE IF EXISTS songs")

#cretae the table if it doesn't exist with given columns
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

#execute the sql
DB[:conn].execute(sql)

#return database row as a has with the column names as keys
DB[:conn].results_as_hash = true
