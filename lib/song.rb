require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  #changes Song to songs
  def self.table_name
    self.to_s.downcase.pluralize
  end
 
  #gets column names
  def self.column_names
  #when a SELECT statement is executed, 
  #don't return a database row as an array, return it as a 
  #hash with the column names as keys.
    DB[:conn].results_as_hash = true
    #query table for names of columns & will return an array of hashes with column info
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    #iterate over the array of hashes to get just the name of each column
    table_info.each do |row|
      column_names << row["name"]
    end
    #.compact will get rid of any nil values
    column_names.compact
  end

  #iterate over the column names stored in the column_names class method 
  #and set an attr_accessor for each one
  self.column_names.each do |col_name|
  #convert the column name string into a symbol with the #to_sym method, 
  #since attr_accessors must be named with symbols.
    attr_accessor col_name.to_sym
  end

  #takes in an argument of options, which is an empty hash 
  def initialize(options={})
    options.each do |property, value|
  #send method to interpolate the name of each hash key as a method 
  #that we set = to that key's value
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



