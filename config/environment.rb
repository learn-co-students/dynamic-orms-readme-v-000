require 'sqlite3' #require sqlite3 gem


DB = {:conn => SQLite3::Database.new("db/songs.db")} #setup database connection
DB[:conn].execute("DROP TABLE IF EXISTS songs") #create a table called songs (if not done already)

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)    #sets up the table based on SQL above
DB[:conn].results_as_hash = true  #interesting! Providing the execution results as a hash? Much nicer than an array..., keys are column names, BTW
