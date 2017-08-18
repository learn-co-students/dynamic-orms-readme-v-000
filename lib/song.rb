require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    #abstracts the table name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    #results_as_hash is a SQLite3::Database method that uses bool to decide if rows should be returned as hashes (arrays is default). In the hash, the column names are keys

    sql = "pragma table_info('#{table_name}')"
    #returns an array of hashes and each hash contains info about a column

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
    #compact => removes nil values from the array
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
    #create attr_accessor(s) from the column names
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
    #use metaprogramming to set the attributes for the object
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
    #gives you the table name in the correct format for INSERT INTO statement
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
    #get the values that you want to INSERT INTO the table
    #uses reader method (attr_reader) to accomplish
    #use send to invoke the method and then capture the return value
    #the unless nil? part is to make sure we don't capture the id value
    #use single quotes because SQL expects the column value this way
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #gives you the column names in the correct format for INSERT INTO statement
    #it DOES NOT include the id attribute
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
    #select records 
  end

end
