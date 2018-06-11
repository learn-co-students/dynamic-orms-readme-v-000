require_relative "../config/environment.rb"
require 'active_support/inflector'   #allows us to use pluralize

class Song


  def self.table_name
    self.to_s.downcase.pluralize   #take our selves (Song class) convert to string, doncase, add an s as per the convention.
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"  #nthis is going to request info from the table, not sure why table_name works though....

    table_info = DB[:conn].execute(sql) #execute it
    column_names = []
    table_info.each do |row|
      column_names << row["name"]   #shovel the column names into the array
    end
    column_names.compact  #gets rid of nil values from column names
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym       #adds an attr_accessor for each column name! (Fun!), makes it into a symbol
  end

  def initialize(options={})  #a generalized intiailize that can take a hash and make the correct assignments from it.
    options.each do |property, value|
      self.send("#{property}=", value)  #calls the equivalent of self.property=value
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert #tosses this to the sql query above (through some kind of black magic) for us in all-purpose save method
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?   #for each column name, send(col_name) because it will be the key of the hash in the return
    end
    values.join(", ")  #formal for sql query
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")  #don't want to insert id, will ruin the primary key
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'" #all you need is the table name here, everything else is already generalized!
    DB[:conn].execute(sql)
  end

end
