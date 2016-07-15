require 'sqlite3'

  # This creates the database:
  # 1. Drop songs to avoid an error.
  # 2. Create the songs table.

DB = {:conn => SQLite3::Database.new("db/students.db")}
DB[:conn].execute("DROP TABLE IF EXISTS songs")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

# The following method says:
# When a SELECT statement is executed, don't return a database row as an array,
# return it as a hash with the column names as keys.

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true

# Returns => {"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello", 2 => "25"}
