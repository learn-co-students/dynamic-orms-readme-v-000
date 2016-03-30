require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name #method that returns name of a table, given name of the class
    self.to_s.downcase.pluralize
    #pluralize allowed by active_support/inflector
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    #query a table for names of its columns
    #by using PRAGMA keyword and #table_name method
    table_info = DB[:conn].execute(sql) #returns array of hashes of column information
    column_names = []
    table_info.each do |row| #iterate over every hash 
      column_names << row["name"] #collect only name of each column
    end
    column_names.compact #get rid of any nil values
    #returns array of column names ["id", "name", "album"]
  end

  self.column_names.each do |col_name| #iterate over every column name
    attr_accessor col_name.to_sym #convert column name string into symbol 
  end
  #example of metaprogramming: reader & writer method for each column is dynamically created
  #without having to explicitly name each of those methods

  def initialize(options={}) #take in hash of keyword arguments w/o explicitly naming those arguments
    #takes in an argument of options, with defaults to an empty hash
    options.each do |property, value|
      self.send("#{property}=", value) #send method interpolates the name of each hash key as a method (key=)
      #same as self.#{property} = value
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert #in order to use a class method inside an instance method
    self.class.table_name
  end

  def col_names_for_insert 
    #delete id column because we don't INSERT id attribute 
    #when we INSERT a row into a DB table for the first time
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #.join(", ") will turn array into comma separated list, in a string
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
      #use #send on each col. name to invoke the method by that same name
      #and then capture return value
      #send(col_name) will give value 
      #{send(col_name)} necessary for interpolation
      #'#{send(col_name)}' necessary for final SQL string formatting
    end
    values.join(", ") #separate array into comma separated values
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



