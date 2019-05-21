require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    #line 11 takes the name of the class, referenced by the self keyword,
    #turns it into a string with #to_s, downcases (or "un-capitalizes") that string and then "pluralizes" it,
    # or makes it plural.
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    #line 19 queries a table for the names of its columns
    #Returns an array of hashes describing the table itself
    #Each hash will contain information about one column
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    #iterate over the resulting array of hashes to collect just the name of each column
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact #calling #compact to be safe and get rid of any nil values that may end up in our collection
    #The return value of calling Song.column_names will therefore be
    #["id", "name", "album"]
  end
  #The following tells Song class that it should have an attr_accessor named after each column
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    options.each do |property, value|
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
      #programmatically invoke a method, without knowing the exact name of the method, using the #send method
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #This will return "name, album"
    #Without the join, returns ["name", "album"]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
