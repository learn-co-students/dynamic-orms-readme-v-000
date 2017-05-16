require_relative "../config/environment.rb"

# The active_support/inflector code library
# provides the pluralize method
require 'active_support/inflector'

class Song


  def self.table_name
    # returns the name of the table, pluralized
    self.to_s.downcase.pluralize
  end

  def self.column_names
    # Use the results_as_hash method, available to use from the SQLite3-Ruby gem.
    # This method says: when a SELECT statement is executed, don't return a
    # database row as an array, return it as a hash with the column names as keys.
    DB[:conn].results_as_hash = true

    # Query the table for the names of its columns
    # Returns an array of hashes describing the table itself
    # Each hash has a "name" key that points to a value of the column name
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    # Call compact to get rid of any nil values that may end up in the collection
    # The return value of calling Song.column_names will therefore be:
    # ["id", "name", "album"]
    column_names.compact
  end

  # Iterate over the column names and set an attr_accessor for each one,
  # making sure to convert the column name string into a symbol with the 
  # to_sym method, since attr_accessors must be named with symbols
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  # Iterate over the options hash and use the send method to interpolate
  # the name of each hash key as a method and set equal to that key's value.
  # As long as each property has a corresponding attr_accessor,
  # this initialize method will work
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    # Get the values to insert by grabbing the values of the instance's attr_readers
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    # Access the table name to INSERT into from inside the save method
    self.class.table_name
  end

  def col_names_for_insert
    # Remove "id" from the array of column names. Returns: ["name", "album"]
    # and turns them into a comma separated list, contained in a string
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    # Iterate over the column names stored in column_names and use the 
    # send method with each individual column name to invoke the method
    # by that same name and capture the return value
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    # Join this array into a string
    values.join(", ")
  end

  def self.find_by_name(name)
    # Uses the table_name class method that will return the
    # table name associated with any given class
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
