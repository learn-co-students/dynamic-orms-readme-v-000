require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  def self.table_name
    # Returns the name of a table, given the name of a class
    self.to_s.downcase.pluralize
  end

  def self.column_names
    # Queries table for names of its columns
    # Returns array of hashes describing table
    # Each hash has info about one column
    # Iterate over the resulting array of hashes to collect just the name of each column
    # Return value will be ["id", "name", "album"]
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    # Calling .compact removes any nil values from collection
    # This collection is used to create attr_accessors for Song class
    column_names.compact
  end

  self.column_names.each do |col_name|
    # Creates attr_accessors using column names; converts to symbols
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    # Builds dynamic initialize method
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
