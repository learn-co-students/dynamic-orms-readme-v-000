require 'sqlite3'

# Creating the database.
DB = {:conn => SQLite3::Database.new("db/students.db")}
# Drop songs to avoid an error.
DB[:conn].execute("DROP TABLE IF EXISTS songs")
# Creating the songs table.
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true

# #results_as_hash method, available to use from the SQLite3-Ruby gem. This method says: when a SELECT statement is executed, don't return a database row as an array, return it as a hash with the column names as keys.
# So, instead of DB[:conn].execute("SELECT * FROM songs LIMIT 1") returning something that looks like this:
# [[1, "Hello", "25"]]
# It will return something that looks like this:
# {"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello", 2 => "25"}
